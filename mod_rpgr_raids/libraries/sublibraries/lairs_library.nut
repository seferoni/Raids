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
    Factions =
    [
        ::Const.FactionType.Zombies,
        ::Const.FactionType.Undead,
        ::Const.FactionType.Orcs,
        ::Const.FactionType.Bandits,
        ::Const.FactionType.Goblins,
        ::Const.FactionType.Barbarians,
        ::Const.FactionType.OrientalBandits
    ],
    Parameters =
    {
        FactionSpecificNamedLootChance = 33,
        MaximumLootOffset = 3,
        NamedItemChanceOnSpawn = 30,
        NamedItemChancePerAgitationTier = 13.33,
        NamedLootRefreshChance = 60,
        ResourceModifierLowerBound = 200,
        ResourceModifierUpperBound = 350,
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
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

    function getScaledLootCount( _lair )
    {   // TODO: this should take into account resources and edicts
        local resources = _lair.getResources(),
        quantity = ::Math.ceil(resources / 100);

        if (Raids.Edicts.findEdict("special.edict_of_abundance", _lair, true) != false)
        {
            quantity += Raids.Edicts.Parameters.AbundanceOffset;
        }

        return ::Math.min(this.Parameters.MaximumLootOffset, quantity); // FIXME: this should check if stackable
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

    function getCandidateAtPosition( _position )
    {
        local Raids = ::RPGR_Raids, entities = ::World.getAllEntitiesAndOneLocationAtPos(_position, 1.0),
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

            if (Raids.Lairs.isActiveContractLocation(_entity))
            {
                return false;
            }

            return true;
        });

        if (lairs.len() == 0)
        {
            return null;
        }

        return lairs[0];
    }

    function getCandidatesWithin( _tile, _distance = 6 )
    {
        local Lairs = ::RPGR_Raids.Lairs,
        lairs = ::World.EntityManager.getLocations().filter(function( _index, _location )
        {
            if (!Lairs.isLocationTypeViable(_location.getLocationType()))
            {
                return false;
            }

            if (_tile.getDistanceTo(_location.getTile()) > _distance)
            {
                return false;
            }

            if (Lairs.isActiveContractLocation(_location))
            {
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
            if (!Raids.Lairs.isLocationTypeViable(_location.getLocationType()))
            {
                return false;
            }

            if (!Raids.Shared.isPlayerInProximityTo(_location.getTile()))
            {
                return false;
            }

            if (Raids.Lairs.isActiveContractLocation(_location))
            {
                return false;
            }

            return true;
        }));

        return lairs;
    }

    function getNaiveNamedLootChance( _lair )
    {
        local tile = _lair.getTile(), closestDistance = 9000;

		foreach( settlement in ::World.EntityManager.getSettlements() )
		{
			local distance = tile.getDistanceTo(settlement.getTile());
			if (distance < closestDistance) closestDistance = distance;
		}

		return (_lair.getResources() + closestDistance * 4) / 5.0 - 37.0;
    }

    function getNamedLootChance( _lair )
    {
        return Raids.Standard.getFlag("BaseNamedItemChance", _lair) + ((Raids.Standard.getFlag("Agitation", _lair) - 1) * this.Parameters.NamedItemChancePerAgitationTier);
    }

    function getResourceDifference( _lair, _lairResources, _partyResources )
    {
        local naiveDifference = _lairResources - _partyResources,
        edictModifier = Raids.Edicts.findEdict("special.edict_of_provocation", _lair, true) != false ? 2.5 : 1.0,
        baseResourceModifier = this.getBaseResourceModifier(Raids.Standard.getFlag("BaseResources", _lair)),
        configurableModifier = Raids.Standard.getPercentageSetting("RoamerResourceModifier");
        return baseResourceModifier * edictModifier * configurableModifier * naiveDifference;
    }

    function getTimeModifier()
    {
        return (0.9 + ::Math.minf(2.0, ::World.getTime().Days * 0.014) * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()]);
    }

    function getTooltipEntries( _lair )
    {
        local agitation = Raids.Standard.getFlag("Agitation", _lair),
        textColour = "PositiveValue", iconPath = "vision.png";

        if (agitation != this.AgitationDescriptors.Relaxed)
        {
            textColour = "NegativeValue", iconPath = "miniboss.png";
        }

        local resourcesEntry = {id = 20, type = "text"}, agitationEntry = clone resourcesEntry;
        resourcesEntry.icon <- "ui/icons/asset_money.png";
        agitationEntry.icon <- format("ui/icons/%s", iconPath);
        resourcesEntry.text <- format("%s resource units", Raids.Standard.colourWrap(format("%i", _lair.getResources()), "PositiveValue"));
        agitationEntry.text <- format("%s", Raids.Standard.colourWrap(format("%s (%i)", Raids.Standard.getDescriptor(agitation, this.AgitationDescriptors), agitation), textColour));

        return [resourcesEntry, agitationEntry];
    }

    function initialiseLairParameters( _lair )
    {
        Raids.Standard.setFlag("BaseResources", _lair.getResources(), _lair);
        Raids.Standard.setFlag("Agitation", this.AgitationDescriptors.Relaxed, _lair);
        Raids.Standard.setFlag("BaseNamedItemChance", this.getNaiveNamedLootChance(_lair), _lair);
    }

    function isActiveContractLocation( _lair )
    {
        local activeContract = ::World.Contracts.getActiveContract();

		if (activeContract == null || !("Destination" in activeContract.m))
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
        local factionType = _faction.getType();

        foreach( viableFaction in this.Factions )
        {
            if (factionType == viableFaction)
            {
                return true;
            }
        }

        return false;
    }

    function isLairViable( _lair, _checkContract = true, _checkProximity = false )
    {
        if (!this.isLocationTypeViable(_lair.getLocationType()))
        {
            return false;
        }

        if (this.isActiveContractLocation(_lair))
        {
            return false;
        }

        if (_checkProximity && !Raids.Shared.isPlayerInProximityTo(_lair.getTile(), 1))
        {
            return false;
        }

        return true;
    }

    function isLairViableForProcedure( _lair, _procedure )
    {
        local agitation = Raids.Standard.getFlag("Agitation", _lair);

        if (_procedure == this.Procedures.Increment && agitation >= this.AgitationDescriptors.Militant)
        {
            Raids.Standard.log(format("Agitation for %s is capped, aborting procedure.", _lair.getName()));
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitation <= this.AgitationDescriptors.Relaxed)
        {
            Raids.Standard.log(format("Agitation for %s is already at its minimum value, aborting procedure.", _lair.getName()));
            return false;
        }

        Raids.Standard.log(format("Lair %s is viable for agitation state change procedures.", _lair.getName()));
        return true;
    }


    function isLocationTypeViable( _locationType )
    {
        return _locationType == ::Const.World.LocationType.Lair || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Mobile);
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

        local namedLoot = Raids.Shared.createNamedLoot(_lair);

        for ( local i = 0; i < iterations ; i++ )
        {
            local namedItem = namedLoot[::Math.rand(0, namedLoot.len() - 1)];
            _lair.getLoot().add(::new(format("scripts/items/%s", namedItem)));
            Raids.Standard.log(format("Added item with filepath %s to the inventory of %s.", namedItem, _lair.getName()));
        }
    }

    function setAgitation( _lair, _procedure )
    {
        if (!this.isLairViableForProcedure(_lair, _procedure))
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
        this.updateProperties(_lair, _procedure);
    }

    function setResourcesByAgitation( _lair )
    {
        local agitation = Raids.Standard.getFlag("Agitation", _lair),
        baseResources = Raids.Standard.getFlag("BaseResources", _lair),
        interpolatedModifier = -0.0006 * baseResources + 0.4,
        configurableModifier = Raids.Standard.getPercentageSetting("AgitationResourceModifier");
        _lair.setResources(::Math.floor(baseResources + (interpolatedModifier * (agitation - 1) * configurableModifier * baseResources)));
    }

    function updateCombatStatistics( _isParty )
    {
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

        for( local i = 0; i < decrementIterations; i++ )
        {
            this.setAgitation(_lair, this.Procedures.Decrement);

            if (Raids.Standard.getFlag("Agitation", _lair) == this.AgitationDescriptors.Relaxed)
            {
                break;
            }
        }
    }

    function updateProperties( _lair, _procedure )
    {
        if (_procedure == this.Procedures.Reset)
        {
            Raids.Edicts.clearEdicts(_lair);
        }

        this.setResourcesByAgitation(_lair);
        _lair.createDefenders();
        _lair.setLootScaleBasedOnResources(_lair.getResources());

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

        this.repopulateLairNamedLoot(_lair);
    }
};