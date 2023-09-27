::RPGR_Raids.Lairs <-
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
        NamedLootRefreshChance = 60, // TODO: balance this
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
            return !::RPGR_Raids.isActiveContractLocation(_lair) && _lair.getFlags().get("Agitation") != this.AgitationDescriptors.Militant;
        });

        if (viableLairs.len() == 0)
        {
            this.log("agitateViableLairs could not find any viable lairs within proximity of the player.");
            return;
        }

        for( local i = 0; i < _iterations; i++ )
        {
            foreach( lair in viableLairs )
            {
                this.log(format("Performing agitation increment procedure on %s.", lair.getName()));
                this.setLairAgitation(lair, this.Procedures.Increment, false);
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
                this.log(format("depopulateLairNamedLoot removed %s from the inventory of lair %s.", item.getName(), _lair.getName()));
                break;
            }
        }
    }

    function findLairCandidates( _faction )
    {
        local lairs = [];

        if (_faction.getSettlements().len() == 0)
        {
            this.log("findLairCandidates was passed a viable faction as an argument, but this faction has no settlements at present.");
            return lairs;
        }

        this.log("Proceeding to lair candidate selection.");
        lairs.extend(_faction.getSettlements().filter(function( _locationIndex, _location )
        {
            return ::RPGR_Raids.isLocationTypeViable(_location.getLocationType()) && ::RPGR_Raids.isPlayerInProximityTo(_location.getTile());
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
            else if (!::RPGR_Raids.isLocationTypeViable(_entity.getLocationType()))
            {
                ::RPGR_Raids.log(format("%s is not an viable lair.", _entity.getName()));
                return false;
            }

            return true;
        });

        return lairs;
    }

    function getNaiveNamedLootChance( _lair )
    {
        local nearestSettlementDistance = 9000;
		local lairTile = _lair.getTile();

		foreach( settlement in ::World.EntityManager.getSettlements() )
		{
			local distance = lairTile.getDistanceTo(settlement.getTile());

			if (distance < nearestSettlementDistance)
			{
				nearestSettlementDistance = distance;
			}
		}

		return (_lair.getResources() + nearestSettlementDistance * 4) / 5.0 - 37.0;
    }

    function getNamedLootChance( _lair )
    {
        local flags = _lair.getFlags();
        return flags.get("BaseNamedItemChance") + (flags.get("Agitation") - 1) * 13.33;
    }

    function initialiseLairParameters( _lair )
    {
        local flags = _lair.getFlags();
        flags.set("BaseResources", _lair.m.Resources);
        flags.set("Agitation", this.AgitationDescriptors.Relaxed);
        flags.set("BaseNamedItemChance", this.getNaiveNamedLootChance(_lair))
    }

    function initialiseVanguardParameters( _party )
    {
        local partyName = _party.getName();
        ::RPGR_Raids.log(format("%s are eligible for Vanguard status.", partyName));
        _party.setName(format("Vanguard %s", partyName));
        _party.getFlags().set("IsVanguard", true);
        ::RPGR_Raids.addToInventory(_party, ::RPGR_Raids.createNaivePartyLoot(_party, false));
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

        if (activeContract.m.Destination.get() == _lair) // TODO: test this again
        {
            this.log(format("%s was found to be an active contract location, aborting.", lair.getName()));
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
        ];
        local factionType = _faction.getType();

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

    function isLairViableForProcedure( _lair, _procedure )
    {
        local agitationState = _lair.getFlags().get("Agitation"), lairName = _lair.getName;
        local lairName = _lair.getName();

        if (agitationState > this.AgitationDescriptors.Militant || agitationState < this.AgitationDescriptors.Relaxed)
        {
            this.log(format("Agitation for %s occupies an out-of-bounds value.", lairName), true);
            return false;
        }

        if (_procedure == this.Procedures.Increment && agitationState >= this.AgitationDescriptors.Militant)
        {
            this.log(format("Agitation for %s is capped, aborting procedure.", lairName));
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitationState <= this.AgitationDescriptors.Relaxed)
        {
            this.log(format("Agitation for %s is already at its minimum value, aborting procedure.", lairName));
            return false;
        }

        this.log(format("Lair %s is viable for agitation state change procedures.", lairName));
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
        local namedLootChance = this.getNamedLootChance(_lair);
        local iterations = 0;
        this.log(format("namedLootChance is %.2f for lair %s.", namedLootChance, _lair.getName()));

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
            this.log(format("Added item with filepath %s to the inventory of %s.", namedItem, _lair.getName()));
        }
    }

    function selectRandomPartyTemplate( _party, _partyList, _resources )
    {
        local troopsTemplate = [];
        local bailOut = 0, maximumIterations = 10;

        while (troopsTemplate.len() < 1 && bailOut < maximumIterations)
        {
            local partyTemplateCandidate = _partyList[::Math.rand(0, _partyList.len() - 1)];
            troopsTemplate.extend(partyTemplateCandidate.Troops.filter(function( _troopIndex, _troop )
            {
                return _troop.Type.Cost <= _resources && ::RPGR_Raids.isTroopViable(_troop);
            }));
            bailOut += 1;
        }

        if (bailOut == maximumIterations)
        {
            this.log(format("Exceeded maximum iterations for troop assignment for party %s.", _party.getName()));
        }

        return troopsTemplate;
    }

    function setLairAgitation( _lair, _procedure, _updateProperties = true )
    {
        if (!this.isLairViableForProcedure(_lair, _procedure))
        {
            return;
        }

        local flags = _lair.getFlags();

        switch (_procedure)
        {
            case (this.Procedures.Increment):
                flags.increment("Agitation");
                break;

            case (this.Procedures.Decrement):
                flags.increment("Agitation", -1);
                break;

            case (this.Procedures.Reset):
                flags.set("Agitation", this.AgitationDescriptors.Relaxed);
                break;

            default:
                this.log("setLairAgitation was called with an invalid procedure value.", true);
                return;
        }

        flags.set("LastAgitationUpdate", ::World.getTime().Days);

        if (_updateProperties)
        {
            this.updateLairProperties(_lair, _procedure);
        }
    }

    function updateCombatStatistics( _flagStates )
    {
        local worldFlags = ::World.Statistics.getFlags();
        worldFlags.set("LastFoeWasVanguardParty", _flagStates[0]);
        worldFlags.set("LastFoeWasParty", _flagStates[1]);
    }

    function updateCumulativeLairAgitation( _lair )
    {
        local flags = _lair.getFlags(), lastUpdateTimeDays = flags.get("LastAgitationUpdate");

        if (lastUpdateTimeDays == false)
        {
            return;
        }

        local timeDifference = ::World.getTime().Days - lastUpdateTimeDays;
        local decayInterval = this.Mod.ModSettings.getSetting("AgitationDecayInterval").getValue();

        if (timeDifference < decayInterval)
        {
            return;
        }

        this.log(format("Last agitation update occurred %i days ago.", timeDifference));
        local decrementIterations = ::Math.floor(timeDifference / decayInterval);

        for( local i = 0; i != decrementIterations; i = ++i )
        {
            this.setLairAgitation(_lair, this.Procedures.Decrement);

            if (flags.get("Agitation") == this.AgitationDescriptors.Relaxed)
            {
                break;
            }
        }
    }

    function updateLairProperties( _lair, _procedure )
    {
        local flags = _lair.getFlags(), baseResources = flags.get("BaseResources");
        local resourceModifier = -0.0006 * baseResources + 0.4;
        local naiveModifier = this.Mod.ModSettings.getSetting("AgitationResourceModifier").getValue() / 100.0;
        local agitationResourceOffset = resourceModifier * baseResources * (flags.get("Agitation") - 1) * naiveModifier;
        _lair.m.Resources = ::Math.floor(baseResources + agitationResourceOffset);
        this.log("Refreshing lair defender roster on agitation update.");
        _lair.createDefenders();
        _lair.setLootScaleBasedOnResources(_lair.getResources());

        if (_procedure != this.Procedures.Increment)
        {
            this.depopulateLairNamedLoot(_lair);
            return;
        }

        if (::Math.rand(1, 100) > this.Parameters.LairNamedLootRefreshChance && flags.get("Agitation") != this.AgitationDescriptors.Militant)
        {
            this.log(format("Skipping named loot refresh procedure within this agitation cycle for lair %s.", _lair.getName()));
            return;
        }

        this.repopulateLairNamedLoot(_lair);
    }
};