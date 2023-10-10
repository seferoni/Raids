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
        FactionSpecificNamedLootChance = 33,
        MaximumTroopOffset = 7,
        NamedItemChanceOnSpawn = 30,
        NamedItemChancePerAgitationTier = 13.33,
        NamedLootRefreshChance = 60,
        ResourceModifierLowerBound = 200,
        ResourceModifierUpperBound = 350,
        VanguardResourceThreshold = 6,
        VanguardThresholdPercentage = 75.0
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    },

    function addEdict( _party )
    {
        local culledString = "scripts/items/",
        edicts = ::IO.enumerateFiles("scripts/items/misc/edicts").map(@(_stringPath) _stringPath.slice(culledString.len()));
        _party.addToInventory(edicts[::Math.rand(0, edicts.len() - 1)]);
    }

    function agitateViableLairs( _lairs, _iterations = 1 )
    {
        local Raids = ::RPGR_Raids,
        viableLairs = _lairs.filter(function( _lairIndex, _lair )
        {
            return !Raids.Lairs.isActiveContractLocation(_lair) && Raids.Standard.getFlag("Agitation", _lair) != Raids.Lairs.AgitationDescriptors.Militant;
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

        while (_resources >= 0 && bailOut < this.Parameters.MaximumTroopOffset)
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

    function getBaseResourceModifier( _resources )
    {
        local modifier = 1.0;

        if (_resources <= this.Parameters.ResourceModifierLowerBound)
        {
            return modifier;
        }

        if (_resources <= this.Parameters.ResourceModifierUpperBound)
        {
            modifier = -0.005 * _resources + 2.0;
        }
        else
        {
            modifier = 0.25;
        }

        return modifier;
    }

    function getCandidatesAtPosition( _position, _radius )
    {
        local Raids = ::RPGR_Raids, entities = ::World.getAllEntitiesAndOneLocationAtPos(_position, _radius),
        lairs = entities.filter(function( _entityIndex, _entity )
        {
            if (!::isKindOf(_entity, "location"))
            {
                return false;
            }
            else if (!Raids.Lairs.isLocationTypeViable(_entity.getLocationType()))
            {
                Raids.Standard.log(format("%s is not an viable lair.", _entity.getName()));
                return false;
            }

            return true;
        });

        return lairs;
    }

    function getCandidatesByFaction( _faction )
    {
        local lairs = [], Raids = ::RPGR_Raids;

        if (_faction.getSettlements().len() == 0)
        {
            Raids.Standard.log("getCandidatesByFaction was passed a faction that has no settlements at present.");
            return lairs;
        }

        Raids.Standard.log("Proceeding to lair candidate selection.");
        lairs.extend(_faction.getSettlements().filter(function( _locationIndex, _location )
        {
            return Raids.Lairs.isLocationTypeViable(_location.getLocationType()) && Raids.Shared.isPlayerInProximityTo(_location.getTile());
        }));

        return lairs;
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
        return Raids.Standard.getFlag("BaseNamedItemChance", _lair) + (Raids.Standard.getFlag("Agitation", _lair) - 1) * this.Parameters.NamedItemChancePerAgitationTier;
    }

    function getResourceDifference( _lair, _lairResources, _partyResources )
    {
        local baseResourceModifier = this.getBaseResourceModifier(Raids.Standard.getFlag("BaseResources", _lair)),
        naiveDifference = (_lairResources - _partyResources),
        configurableModifier = Raids.Standard.getPercentageSetting("RoamerResourceModifier");
        return baseResourceModifier * configurableModifier * naiveDifference;
    }

    function getTimeModifier()
    {
        return (0.9 + ::Math.minf(2.0, ::World.getTime().Days * 0.014) * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()]);
    }

    function getWorldFaction( _factionIndex )
    {
        return ::World.FactionManager.getFaction(_factionIndex);
    }

    function initialiseLairParameters( _lair )
    {
        Raids.Standard.setFlag("BaseResources", _lair.getResources(), _lair);
        Raids.Standard.setFlag("Agitation", this.AgitationDescriptors.Relaxed, _lair);
        Raids.Standard.setFlag("BaseNamedItemChance", this.getNaiveNamedLootChance(_lair), _lair);
    }

    function initialiseVanguardParameters( _party )
    {
        _party.setName(format("Vanguard %s", _party.getName()));
        Raids.Standard.setFlag("IsVanguard", true, _party);
        this.addEdict(_party);
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
        local agitationState = Raids.Standard.getFlag("Agitation", _lair);

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

    function repopulateNamedLoot( _lair )
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
        local troopsTemplate = [], bailOut = 0, maximumIterations = 10, Raids = ::RPGR_Raids;

        while (troopsTemplate.len() < 1 && bailOut < maximumIterations)
        {
            local partyTemplateCandidate = _partyList[::Math.rand(0, _partyList.len() - 1)];
            troopsTemplate.extend(partyTemplateCandidate.Troops.filter(function( _troopIndex, _troop )
            {
                return _troop.Type.Cost <= _resources && Raids.Lairs.isTroopViable(_troop);
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

        switch (_procedure)
        {
            case (this.Procedures.Increment): Raids.Standard.incrementFlag("Agitation", 1, _lair); break;
            case (this.Procedures.Decrement): Raids.Standard.incrementFlag("Agitation", -1, _lair); break;
            case (this.Procedures.Reset): Raids.Standard.setFlag("Agitation", this.AgitationDescriptors.Relaxed, _lair); break;
            default: Raids.Standard.log("setAgitation was called with an invalid procedure value.", true); return;
        }

        Raids.Standard.setFlag("LastAgitationUpdate", ::World.getTime().Days, _lair);

        if (_updateProperties)
        {
            this.updateLairProperties(_lair, _procedure);
        }
    }

    function setResourcesByAgitation( _lair )
    {
        local baseResources = Raids.Standard.getFlag("BaseResources", _lair), interpolatedModifier = -0.0006 * baseResources + 0.4;
        _lair.m.Resources = ::Math.floor(baseResources + (interpolatedModifier * baseResources * (Raids.Standard.getFlag("Agitation", _lair) - 1) * Raids.Standard.getPercentageSetting("AgitationResourceModifier")));
    }

    function updateCombatStatistics( _isVanguard, _isParty )
    {
        Raids.Standard.setFlag("LastFoeWasVanguardParty", _isVanguard, ::World.Statistics);
        Raids.Standard.setFlag("LastFoeWasParty", _isParty, ::World.Statistics);
    }

    function updateAgitation( _lair )
    {
        local lastUpdateTimeDays = Raids.Standard.getFlag("LastAgitationUpdate", _lair);

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

            if (Raids.Standard.getFlag("Agitation", _lair) == this.AgitationDescriptors.Relaxed)
            {
                break;
            }
        }
    }

    function updateLairProperties( _lair, _procedure )
    {
        this.setResourcesByAgitation(_lair);
        Raids.Standard.log("Refreshing lair defender roster on agitation update.");
        _lair.createDefenders();
        _lair.setLootScaleBasedOnResources(_lair.getResources()); // TODO: investigate if this depopulates loot

        if (_procedure != this.Procedures.Increment)
        {
            this.depopulateLairNamedLoot(_lair);
            return;
        }

        if (::Math.rand(1, 100) > this.Parameters.NamedLootRefreshChance && Raids.Standard.getFlag("Agitation", _lair) != this.AgitationDescriptors.Militant)
        {
            Raids.Standard.log(format("Skipping named loot refresh procedure within this agitation cycle for lair %s.", _lair.getName()));
            return;
        }

        this.repopulateNamedLoot(_lair);
    }
};