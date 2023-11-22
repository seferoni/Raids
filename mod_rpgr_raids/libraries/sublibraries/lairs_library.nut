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
        ::Const.FactionType.Bandits,
        ::Const.FactionType.Barbarians,
        ::Const.FactionType.Goblins,
        ::Const.FactionType.Orcs,
        ::Const.FactionType.OrientalBandits
        ::Const.FactionType.Undead,
        ::Const.FactionType.Zombies,
    ],
    NamedItemKeys =
    [
        "NamedArmors",
        "NamedWeapons",
        "NamedHelmets",
        "NamedShields"
    ],
    Parameters =
    {
        AgitationDecayInterval = 7,
        MaximumLootOffset = 3,
        NamedItemChanceOnSpawn = 30,
        NamedItemChancePerAgitationTier = 13.33,
        NamedLootRefreshChance = 60,
        ResourceModifierCeiling = 0.25,
        ResourceModifierLowerBound = 200,
        ResourceModifierUpperBound = 350,
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    }

    function createNaiveNamedLoot()
    {
        local namedLoot = [];

        foreach( key in this.NamedItemKeys )
        {
            namedLoot.extend(::Const.Items[key]);
        }

        return namedLoot;
    }

    function createNamedLoot( _lair )
    {
        if (::Math.rand(1, 100) > Raids.Standard.getSetting("FactionSpecificNamedLootChance"))
        {
            return this.createNaiveNamedLoot();
        }

        local namedLoot = [],
        keys = this.NamedItemKeys.filter(@(_index, _key) _lair.m[format("%sList", _key)] != null);

        foreach( key in keys )
        {
            namedLoot.extend(_lair.m[format("%sList", key)]);
        }

        if (namedLoot.len() == 0)
        {
            return this.createNaiveNamedLoot();
        }

        return namedLoot;
    }

    function depopulateNamedLoot( _lair, _chance = null )
    {
        if (_lair.getLoot().isEmpty())
        {
            return;
        }

        local namedLootChance = _chance;

        if (_chance == null)
        {
            namedLootChance = this.getNamedLootChance(_lair) + Raids.Edicts.getNamedLootChanceOffset(_lair, true);
        }

        if (namedLootChance <= 0)
        {
            return;
        }

        local stash = _lair.getLoot(),
        loot = stash.getItems().filter(@(_index, _item) _item != null && _item.isItemType(::Const.Items.ItemType.Named));

        foreach( item in loot )
        {
            if (::Math.rand(1, 100) < namedLootChance)
            {
                stash.remove(item);
            }
        }
    }

    function getBaseResourceModifier( _resources )
    {   // The arbitrary coefficients and constants used here are calibrated to ensure smooth scaling behaviour between resource breakpoints.
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
            modifier = this.Parameters.ResourceModifierCeiling;
        }

        return modifier;
    }

    function getCandidateAtPosition( _position )
    {
        local Raids = ::RPGR_Raids, entities = ::World.getAllEntitiesAndOneLocationAtPos(_position, 1.0),
        lairs = entities.filter(function( _index, _entity )
        {
            if (!::isKindOf(_entity, "location"))
            {
                return false;
            }
            else if (!Raids.Lairs.isLocationTypeViable(_entity.getLocationType()))
            {
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
        local lairs = [], Lairs = ::RPGR_Raids.Lairs;

        if (_faction.getSettlements().len() == 0)
        {
            return lairs;
        }

        lairs.extend(_faction.getSettlements().filter(function( _index, _location )
        {
            if (!Lairs.isLocationTypeViable(_location.getLocationType()))
            {
                return false;
            }

            if (!Lairs.isPlayerInProximityTo(_location.getTile()))
            {
                return false;
            }

            if (Lairs.isActiveContractLocation(_location))
            {
                return false;
            }

            return true;
        }));

        return lairs;
    }

    function getMoneyCount( _lair )
    {
        return (_lair.getResources());
    }

    function getNaiveNamedLootChance( _lair )
    {   // The arbitrary coefficients and constants used here are taken verbatim from the vanilla codebase.
        local tile = _lair.getTile(), settlement = this.getSettlementClosestTo(tile);
		return (_lair.getResources() + tile.getDistanceTo(settlement.getTile()) * 4) / 5.0 - 37.0;
    }

    function getNamedLootChance( _lair )
    {
        local baseChance = Raids.Standard.getFlag("BaseNamedItemChance", _lair),
        agitation = Raids.Standard.getFlag("Agitation", _lair);
        return baseChance + ((agitation - 1) * this.Parameters.NamedItemChancePerAgitationTier);
    }

    function getResourceDifference( _lair, _lairResources, _partyResources )
    {
        local naiveDifference = _lairResources - _partyResources,
        baseResourceModifier = this.getBaseResourceModifier(Raids.Standard.getFlag("BaseResources", _lair)),
        configurableModifier = Raids.Standard.getPercentageSetting("RoamerResourceModifier");
        return baseResourceModifier * configurableModifier * naiveDifference;
    }

    function getSettlementClosestTo( _tile )
    {
        local closestSettlement = null,
        closestDistance = 9000;

		foreach( settlement in ::World.EntityManager.getSettlements() )
		{
			local distance = _tile.getDistanceTo(settlement.getTile());
			if (distance < closestDistance) closestDistance = distance, closestSettlement = settlement;
		}

        return closestSettlement;
    }

    function getTimeModifier()
    {
        return (0.9 + ::Math.minf(2.0, ::World.getTime().Days * 0.014) * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()]);
    }

    function getTooltipEntries( _lair )
    {
        local agitation = Raids.Standard.getFlag("Agitation", _lair),
        lastUpdateDays = Raids.Standard.getFlag("LastAgitationUpdate", _lair),
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

        if (!lastUpdateDays || agitation == this.AgitationDescriptors.Relaxed)
        {
            return [resourcesEntry, agitationEntry];
        }

        local timeDifference = (lastUpdateDays + this.Parameters.AgitationDecayInterval) - ::World.getTime().Days,
        timeEntry = clone resourcesEntry;
        timeEntry.icon = "ui/icons/action_points.png";
        timeEntry.text = format("%s day(s)", Raids.Standard.colourWrap(timeDifference, "NegativeValue"));
        return [resourcesEntry, agitationEntry, timeEntry];
    }

    function getTreasureCount( _lair )
    {
        return (::Math.ceil(_lair.getResources() / 100.0));
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

        if (_checkContract && this.isActiveContractLocation(_lair))
        {
            return false;
        }

        if (_checkProximity && !this.isPlayerInProximityTo(_lair.getTile()))
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
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitation <= this.AgitationDescriptors.Relaxed)
        {
            return false;
        }

        return true;
    }

    function isLocationTypeViable( _locationType )
    {
        return _locationType == ::Const.World.LocationType.Lair || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Mobile);
    }

    function isPlayerInProximityTo( _tile, _threshold = 6 )
    {
        return ::World.State.getPlayer().getTile().getDistanceTo(_tile) <= _threshold;
    }

    function repopulateNamedLoot( _lair )
    {
        local namedLootChance = this.getNamedLootChance(_lair) + Raids.Edicts.getNamedLootChanceOffset(_lair), iterations = 0;

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
            _lair.getLoot().add(::new(format("scripts/items/%s", namedItem)));
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
        }

        Raids.Standard.setFlag("LastAgitationUpdate", ::World.getTime().Days, _lair);
        this.updateProperties(_lair, _procedure);
    }

    function setResourcesByAgitation( _lair )
    {
        local agitation = Raids.Standard.getFlag("Agitation", _lair),
        baseResources = Raids.Standard.getFlag("BaseResources", _lair),
        interpolatedModifier = -0.0006 * baseResources + 0.6,
        configurableModifier = Raids.Standard.getPercentageSetting("AgitationResourceModifier"),
        newResources = ::Math.floor(baseResources + (interpolatedModifier * (agitation - 1) * configurableModifier * baseResources));
        _lair.setResources(::Math.min(newResources, 700));
    }

    function updateCombatStatistics( _isParty )
    {
        Raids.Standard.setFlag("LastFoeWasParty", _isParty, ::World.Statistics);
    }

    function updateAgitation( _lair )
    {
        local lastUpdateTimeDays = Raids.Standard.getFlag("LastAgitationUpdate", _lair);

        if (!lastUpdateTimeDays)
        {
            return;
        }

        local timeDifference = ::World.getTime().Days - lastUpdateTimeDays,
        decayInterval = this.Parameters.AgitationDecayInterval;

        if (timeDifference < decayInterval)
        {
            return;
        }

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

        if (_procedure != this.Procedures.Increment)
        {
            Raids.Edicts.clearHistory(_lair);
            this.depopulateNamedLoot(_lair);
        }

        this.setResourcesByAgitation(_lair);
        _lair.createDefenders();
        _lair.setLootScaleBasedOnResources(_lair.getResources());

        if (_procedure != this.Procedures.Increment)
        {
            return;
        }

        Raids.Edicts.refreshEdicts(_lair);

        if (Raids.Standard.getFlag("Agitation", _lair) != this.AgitationDescriptors.Militant && ::Math.rand(1, 100) > this.Parameters.NamedLootRefreshChance)
        {
            return;
        }

        this.repopulateNamedLoot(_lair);
    }
};