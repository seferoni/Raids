local Raids = ::RPGR_Raids;
Raids.Lairs <-
{
    AgitationDescriptors =
    {
        Relaxed = 1,
        Cautious = 2,
        Vigilant = 3,
        Militant = 4
    },
    Parameters =
    {
        MaximumTroopOffset = 7,
        ResourceThreshold = 6,
        VanguardThresholdPercentage = 75.0,
        NamedItemChanceOnSpawn = 30,
        NamedItemChancePerAgitationTier = 13.33,
        NamedLootRefreshChance = 60,
        FactionSpecificNamedLootChance = 33,
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    }

    function agitateViableLairs( _lairs, _iterations = 1 )
    {
        local viableLairs = _lairs.filter(function( _lairIndex, _lair )
        {
            return !::RPGR_Raids.Lairs.isActiveContractLocation(_lair) && _lair.getFlags().get("Agitation") != ::RPGR_Raids.Lairs.AgitationDescriptors.Militant;
        });

        if (viableLairs.len() == 0)
        {
            Raids.Standard.log("agitateViableLairs could not find any viable lairs within proximity of the player.");
            return;
        }

        for( local i = 0; i < _iterations; i++ )
        {
            foreach( lair in viableLairs )
            {
                Raids.Standard.log(format("Performing agitation increment procedure on %s.", lair.getName()));
                this.setAgitation(lair, this.Procedures.Increment, false);
            }
        }

        foreach( lair in viableLairs )
        {
            this.updateLairProperties(lair, this.Procedures.Increment);
        }
    }

    function assignTroops( _party, _partyList, _resources )
    {
        local troopsTemplate = this.selectRandomPartyTemplate(_party, _partyList, _resources);

        if (troopsTemplate.len() == 0)
        {
            return false;
        }

        local bailOut = 0;

        while (_resources >= 0 && bailOut < this.Parameters.AssignmentMaximumTroopOffset)
        {
            local troop = troopsTemplate[::Math.rand(0, troopsTemplate.len() - 1)];
            ::Const.World.Common.addTroop(_party, troop, false);
            _resources -= troop.Type.Cost;
            bailOut += 1;
        }

        _party.updateStrength();
        return true;
    }

    function depopulateLairNamedLoot( _lair, _chance = null )
    {
        if (_lair.getLoot().isEmpty())
        {
            return;
        }

        local namedLootChance = _chance == null ? this.getNamedLootChance(_lair) : _chance;
        local items = _lair.getLoot().getItems();

        if (::Math.rand(1, 100) <= namedLootChance)
        {
            return;
        }

        foreach( itemIndex, item in items )
        {
            if (item.isItemType(::Const.Items.ItemType.Named))
            {
                items.remove(itemIndex);
                Raids.Standard.log(format("depopulateLairNamedLoot removed %s from the inventory of lair %s.", item.getName(), _lair.getName()));
                break;
            }
        }
    }

    function findLairCandidates( _faction )
    {
        local lairs = [];

        if (_faction.getSettlements().len() == 0)
        {
            Raids.Standard.log("findLairCandidates was passed a viable faction as an argument, but this faction has no settlements at present.");
            return lairs;
        }

        Raids.Standard.log("Proceeding to lair candidate selection.");
        lairs.extend(_faction.getSettlements().filter(function( _locationIndex, _location )
        {
            return ::RPGR_Raids.Lairs.isLocationTypeViable(_location.getLocationType()) && ::RPGR_Raids.Shared.isPlayerInProximityTo(_location.getTile());
        }));

        return lairs;
    }

    function findLairCandidatesAtPosition( _position, _radius )
    {
        local entities = ::World.getAllEntitiesAndOneLocationAtPos(_position, _radius);
        local lairs = entities.filter(function( _entityIndex, _entity )
        {
            if (!::isKindOf(_entity, "location"))
            {
                return false;
            }
            else if (!::RPGR_Raids.Lairs.isLocationTypeViable(_entity.getLocationType()))
            {
                ::RPGR_Raids.Standard.log(format("%s is not an viable lair.", _entity.getName()));
                return false;
            }

            return true;
        });

        return lairs;
    }

    function getBaseResourceModifier( _resources )
    {
        return _resources >= 200 ? (_resources <= 350 ? -0.005 * _resources + 2.0 : 0.25) : 1.0;
    }

    function getNaiveNamedLootChance( _lair )
    {
        local nearestSettlementDistance = 9000, lairTile = _lair.getTile();

		foreach( settlement in ::World.EntityManager.getSettlements() )
		{
			local settlementDistance = lairTile.getDistanceTo(settlement.getTile());

			if (settlementDistance < nearestSettlementDistance)
			{
				nearestSettlementDistance = settlementDistance;
			}
		}

		return (_lair.getResources() + nearestSettlementDistance * 4) / 5.0 - 37.0;
    }

    function getNamedLootChance( _lair )
    {
        local flags = _lair.getFlags();
        return flags.get("BaseNamedItemChance") + (flags.get("Agitation") - 1) * this.Parameters.NamedItemChancePerAgitationTier;
    }

    function getResourceDifference( _lair, _lairResources, _partyResources )
    {
        local baseResourceModifier = this.getBaseResourceModifier(_lair.getFlags().get("BaseResources")),
        naiveDifference = (_lairResources - _partyResources),
        configurableModifier = Raids.Standard.getPercentageSetting("RoamerResourceModifier");
        return baseResourceModifier * configurableModifier * naiveDifference;
    }

    function getTimeModifier()
    {
        return (0.9 + ::Math.minf(2.0, ::World.getTime().Days * 0.014) * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()]);
    }

    function initialiseLairParameters( _lair )
    {
        local flags = _lair.getFlags();
        flags.set("BaseResources", _lair.getResources());
        flags.set("Agitation", this.AgitationDescriptors.Relaxed);
        flags.set("BaseNamedItemChance", this.getNaiveNamedLootChance(_lair))
    }

    function initialiseVanguardParameters( _party )
    {
        _party.setName(format("Vanguard %s", _party.getName()));
        _party.getFlags().set("IsVanguard", true);
        Raids.Shared.addToInventory(_party, Raids.Shared.createNaivePartyLoot(_party, false));
    }

    function isActiveContractLocation( _lair )
    {
        local activeContract = ::World.Contracts.getActiveContract();

        if (activeContract == null)
        {
            return false;
        }

        if (!("Destination" in activeContract.m))
        {
            return false;
        }

        if (activeContract.m.Destination.get() == _lair)
        {
            Raids.Standard.log(format("%s was found to be an active contract location, aborting.", lair.getName()));
            return true;
        }

        return false;
    }

    function isFactionViable( _faction )
    {
        local inclusionList =
        [
            ::Const.FactionType.Zombies,
            ::Const.FactionType.Undead,
            ::Const.FactionType.Orcs,
            ::Const.FactionType.Bandits,
            ::Const.FactionType.Goblins,
            ::Const.FactionType.Barbarians,
            ::Const.FactionType.OrientalBandits
        ],
        factionType = _faction.getType();

        foreach( includedFaction in inclusionList )
        {
            if (factionType == includedFaction)
            {
                return true;
            }
        }

        return false;
    }

    function isLocationTypeViable( _locationType )
    {
        return _locationType == ::Const.World.LocationType.Lair || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Mobile);
    }

    function isLairViable( _lair, _procedure )
    {
        local agitationState = _lair.getFlags().get("Agitation");

        if (agitationState > this.AgitationDescriptors.Militant || agitationState < this.AgitationDescriptors.Relaxed)
        {
            Raids.Standard.log(format("Agitation for %s occupies an out-of-bounds value.", _lair.getName()), true);
            return false;
        }

        if (_procedure == this.Procedures.Increment && agitationState >= this.AgitationDescriptors.Militant)
        {
            Raids.Standard.log(format("Agitation for %s is capped, aborting procedure.", _lair.getName()));
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitationState <= this.AgitationDescriptors.Relaxed)
        {
            Raids.Standard.log(format("Agitation for %s is already at its minimum value, aborting procedure.", _lair.getName()));
            return false;
        }

        Raids.Standard.log(format("Lair %s is viable for agitation state change procedures.", _lair.getName()));
        return true;
    }

    function isTroopViable( _troop )
    {
        local exclusionList =
        [
            ::Const.World.Spawn.Troops.BarbarianBeastmaster,
            ::Const.World.Spawn.Troops.BarbarianDrummer,
            ::Const.World.Spawn.Troops.BarbarianUnhold,
            ::Const.World.Spawn.Troops.Necromancer,
            ::Const.World.Spawn.Troops.Warhound
        ]

        foreach( excludedTroop in exclusionList )
        {
            if (_troop.Type == excludedTroop)
            {
                return false;
            }
        }

        return true;
    }

    function repopulateLairNamedLoot( _lair )
    {
        local namedLootChance = this.getNamedLootChance(_lair), iterations = 0;
        Raids.Standard.log(format("namedLootChance is %.2f for lair %s.", namedLootChance, _lair.getName()));

        if (namedLootChance > 100)
        {
            iterations += ::Math.floor(namedLootChance / 100);
        }

        if (::Math.rand(1, 100) <= namedLootChance - (iterations * 100))
        {
            iterations += 1;
        }

        if (iterations == 0)
        {
            return;
        }

        local namedLoot = this.createNamedLoot(_lair);

        for ( local i = 0; i < iterations ; i++ )
        {
            local namedItem = namedLoot[::Math.rand(0, namedLoot.len() - 1)];
            _lair.getLoot().add(::new("scripts/items/" + namedItem));
            Raids.Standard.log(format("Added item with filepath %s to the inventory of %s.", namedItem, _lair.getName()));
        }
    }

    function selectRandomPartyTemplate( _party, _partyList, _resources )
    {
        local troopsTemplate = [], bailOut = 0, maximumIterations = 10;

        while (troopsTemplate.len() < 1 && bailOut < maximumIterations)
        {
            local partyTemplateCandidate = _partyList[::Math.rand(0, _partyList.len() - 1)];
            troopsTemplate.extend(partyTemplateCandidate.Troops.filter(function( _troopIndex, _troop )
            {
                return _troop.Type.Cost <= _resources && ::RPGR_Raids.Lairs.isTroopViable(_troop);
            }));
            bailOut += 1;
        }

        if (bailOut == maximumIterations)
        {
            Raids.Standard.log(format("Exceeded maximum iterations for troop assignment for party %s.", _party.getName()));
        }

        return troopsTemplate;
    }

    function setAgitation( _lair, _procedure, _updateProperties = true )
    {
        if (!this.isLairViable(_lair, _procedure))
        {
            return;
        }

        local flags = _lair.getFlags();

        switch (_procedure)
        {
            case (this.Procedures.Increment): flags.increment("Agitation"); break;
            case (this.Procedures.Decrement): flags.increment("Agitation", -1); break;
            case (this.Procedures.Reset): flags.set("Agitation", this.AgitationDescriptors.Relaxed); break;
            default: Raids.Standard.log("setAgitation was called with an invalid procedure value.", true); return;
        }

        flags.set("LastAgitationUpdate", ::World.getTime().Days);

        if (_updateProperties)
        {
            this.updateLairProperties(_lair, _procedure);
        }
    }

    function updateCombatStatistics( _isVanguard, _isParty )
    {
        local worldFlags = ::World.Statistics.getFlags();
        worldFlags.set("LastFoeWasVanguardParty", _isVanguard);
        worldFlags.set("LastFoeWasParty", _isParty);
    }

    function updateAgitation( _lair )
    {
        local flags = _lair.getFlags(), lastUpdateTimeDays = flags.get("LastAgitationUpdate");

        if (lastUpdateTimeDays == false)
        {
            return;
        }

        local timeDifference = ::World.getTime().Days - lastUpdateTimeDays,
        decayInterval = Raids.Standard.getSetting("AgitationDecayInterval");

        if (timeDifference < decayInterval)
        {
            return;
        }

        Raids.Standard.log(format("Last agitation update occurred %i days ago.", timeDifference));
        local decrementIterations = ::Math.floor(timeDifference / decayInterval);

        if (decrementIterations == 0)
        {
            return;
        }

        for( local i = 0; i != decrementIterations; i = ++i )
        {
            this.setAgitation(_lair, this.Procedures.Decrement);

            if (flags.get("Agitation") == this.AgitationDescriptors.Relaxed)
            {
                break;
            }
        }
    }

    function updateLairProperties( _lair, _procedure )
    {
        local flags = _lair.getFlags(), baseResources = flags.get("BaseResources"),
        interpolatedModifier = -0.0006 * baseResources + 0.4,
        configurableModifier = Raids.Standard.getPercentageSetting("AgitationResourceModifier");
        _lair.m.Resources = ::Math.floor(baseResources + (interpolatedModifier * baseResources * (flags.get("Agitation") - 1) * configurableModifier));

        Raids.Standard.log("Refreshing lair defender roster on agitation update.");
        _lair.createDefenders();
        _lair.setLootScaleBasedOnResources(_lair.getResources());

        if (_procedure != this.Procedures.Increment)
        {
            this.depopulateLairNamedLoot(_lair);
            return;
        }

        if (::Math.rand(1, 100) > this.Parameters.NamedLootRefreshChance && flags.get("Agitation") != this.AgitationDescriptors.Militant)
        {
            Raids.Standard.log(format("Skipping named loot refresh procedure within this agitation cycle for lair %s.", _lair.getName()));
            return;
        }

        this.repopulateLairNamedLoot(_lair);
    }
};