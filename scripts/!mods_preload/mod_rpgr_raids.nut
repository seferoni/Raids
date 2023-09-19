::RPGR_Raids <-
{
    ID = "mod_rpgr_raids",
    Name = "RPG Rebalance - Raids",
    Version = "1.0.0",
    AgitationDescriptors =
    {
        Relaxed = 1,
        Cautious = 2,
        Vigilant = 3,
        Militant = 4
    },
    CaravanWealthDescriptors =
    {
        Light = 1,
        Moderate = 2,
        Plentiful = 3,
        Abundant = 4
    },
    CaravanCargoDescriptors =
    {
        Supplies = 1,
        Trade = 2,
        Assortment = 3,
        Unassorted = 4
    },
    CampaignModifiers =
    {
        AssignmentMaximumTroopOffset = 7,
        AssignmentResourceThreshold = 6,
        AssignmentVanguardThresholdPercentage = 75.0,
        CaravanNamedItemChance = 50, // FIXME: this is inflated, revert to 5
        GlobalProximityTiles = 9,
        LairNamedItemChanceOnSpawn = 30,
        LairNamedLootRefreshChance = 50, // TODO: balance this
        LairFactionSpecificNamedLootChance = 33,
        ReinforcementMaximumTroopOffset = 7,
        ReinforcementThresholdDays = 1 // FIXME: this is deflated, revert to 50
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    },

    /* function addToCaravanInventory( _caravan, _goodsPool )
    {
        local iterations = ::Math.rand(1, _caravan.getFlags().get("CaravanWealth") - 1);

        for( local i = 0; i < iterations; i++ )
        {
            local good = _goodsPool[::Math.rand(0, _goodsPool.len() - 1)];
            this.logWrapper(format("Added item with filepath %s to caravan inventory.", good));
            _caravan.addToInventory(good);
        }
    }*/

    function addToInventory( _party, _goodsPool, _isCaravan = false )
    {
        local iterations = _isCaravan == true ? ::Math.rand(1, _party.getFlags().get("CaravanWealth") - 1) : ::Math.rand(1, 2);

        for( local i = 0; i < iterations; i++ )
        {
            local good = _goodsPool[::Math.rand(0, _goodsPool.len() - 1)];
            this.logWrapper(format("Added item with filepath %s to inventory of %s.", good, _party.getName()));
            _party.addToInventory(good);
        }
    }

    function agitateViableLairs( _lairs, _iterations = 1 )
    {
        local viableLairs = _lairs.filter(function( _lairIndex, _lair )
        {
            return !::RPGR_Raids.isActiveContractLocation(_lair);
        });

        for( local i = 0; i < _iterations; i++ )
        {
            foreach( lair in viableLairs )
            {
                this.logWrapper("Found lair candidate.");
                this.setLairAgitation(lair, this.Procedures.Increment);
            }
        }
    }

    function areCaravanFlagsInitialised( _flags )
    {
        return _flags.get("CaravanWealth") != false && _flags.get("CaravanCargo") != false;
    }

    function assignTroops( _party, _partyList, _resources )
    {
        local troopsTemplate = this.selectRandomPartyTemplate(_party, _partyList, _resources);

        if (troopsTemplate.len() == 0)
        {
            return false;
        }

        local bailOut = 0;

        while (_resources >= 0 && bailOut < this.CampaignModifiers.AssignmentMaximumTroopOffset)
        {
            local troop = troopsTemplate[::Math.rand(0, troopsTemplate.len() - 1)];
            ::Const.World.Common.addTroop(_party, troop, false);
            _resources -= troop.Type.Cost;
            bailOut += 1;
        }

        _party.updateStrength();
        return true;
    }

    function calculateSettlementSituationModifier( _settlement )
    {
        local modifier = 0;
        local smallestIncrement = 1.0;
        local synergisticSituations =
        [
            "situation.well_supplied",
            "situation.good_harvest",
            "situation.safe_roads"
        ];
        local antagonisticSituations =
        [
            "situation.ambushed_trade_routes",
            "situation.disappearing_villagers",
            "situation.greenskins",
            "situation.raided"
        ];
        local settlementSituations = _settlement.getSituations().map(function( _situation )
        {
            return _situation.getID();
        });

        foreach( situation in settlementSituations )
        {
            if (synergisticSituations.find(situation) != null)
            {
                modifier += smallestIncrement;
            }
            else if (antagonisticSituations.find(situation) != null)
            {
                modifier -= smallestIncrement;
            }
        }

        return modifier;
    }

    function createCaravanCargo( _caravan, _settlement )
    {
        local produce = _settlement.getProduce();
        local flags = _caravan.getFlags();
        local descriptor = this.getDescriptor(flags.get("CaravanCargo"), this.CaravanCargoDescriptors).tolower();
        local actualProduce = produce.filter(function( _index, _value )
        {
            return _value.find(descriptor) != null;
        });

        if (actualProduce.len() == 0)
        {
            this.logWrapper(format("%s has no produce corresponding to caravan cargo type.", _settlement.getName()));
            local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CaravanCargoDescriptors.Assortment : this.CaravanCargoDescriptors.Unassorted;
            flags.set("CaravanCargo", newCargoType);

            if (newCargoType == this.CaravanCargoDescriptors.Assortment)
            {
                return this.createNaivePartyLoot(_caravan);
            }

            return produce;
        }

        return actualProduce;
    }

    function createNaivePartyLoot( _party, _includeSupplies = true )
    {
        local exclusionList =
        [
            "supplies/food_item",
            "supplies/money_item",
            "trade/trading_good_item",
            "supplies/strange_meat_item",
            "supplies/fermented_unhold_heart_item",
            "supplies/black_marsh_stew_item"
        ];
        local southernGoods =
        [
            "supplies/dates_item",
            "supplies/rice_item",
            "trade/silk_item",
            "trade/spices_item",
            "trade/incense_item"
        ];
        local southernFactions =
        [
            ::Const.FactionType.OrientalBandits,
            ::Const.FactionType.OrientalCityState
        ];

        foreach( factionType in southernFactions )
        {
            if (::World.FactionManager.getFaction(_party.getFaction()).getType() == factionType)
            {
                return southernGoods;
            }
        }

        exclusionList.extend(southernGoods);
        local scriptFiles = ::IO.enumerateFiles("scripts/items/trade");

        if (_includeSupplies)
        {
            scriptFiles.extend(::IO.enumerateFiles("scripts/items/supplies"));
        }

        foreach( excludedFile in exclusionList )
        {
            local index = scriptFiles.find("scripts/items/" + excludedFile);

            if (index != null)
            {
                scriptFiles.remove(index);
            }
        }

        local culledString = "scripts/items/";
        local goods = scriptFiles.map(function( _stringPath )
        {
            return _stringPath.slice(culledString.len());
        });
        return goods;
    }

    function createCaravanTroops( _wealth, _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.Billman,
                ::Const.World.Spawn.Troops.Footman,
                ::Const.World.Spawn.Troops.Arbalester,
                ::Const.World.Spawn.Troops.ArmoredWardog
            ]);

            return troops;
        }

        if (_wealth >= this.CaravanWealthDescriptors.Plentiful)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.MercenaryLOW,
            ]);

            if (::World.getTime().Days >= this.CampaignModifiers.ReinforcementThresholdDays)
            {
                troops.extend([
                    ::Const.World.Spawn.Troops.Mercenary,
                    ::Const.World.Spawn.Troops.MercenaryRanged,
                ]);
            }
        }

        if (_factionType == ::Const.FactionType.OrientalCityState)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.Conscript,
                ::Const.World.Spawn.Troops.ConscriptPolearm
            ]);
        }
        else
        {
            troops.extend([
                ::Const.World.Spawn.Troops.CaravanHand,
                ::Const.World.Spawn.Troops.CaravanGuard
            ]);
        }

        return troops;
    }

    function createEliteCaravanTroops( _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.MasterArcher,
                ::Const.World.Spawn.Troops.Greatsword,
                ::Const.World.Spawn.Troops.Knight
            ]);

            return troops;
        }

        troops.extend([
            ::Const.World.Spawn.Troops.HedgeKnight,
            ::Const.World.Spawn.Troops.Swordmaster
        ]);

        return troops;
    }

    function createNaiveNamedLoot( _namedItemKeys )
    {
        local namedLoot = [];

        foreach( key in _namedItemKeys )
        {
            namedLoot.extend(::Const.Items[key]);
        }

        return namedLoot;
    }

    function createNamedLoot( _lair = null )
    {
        local namedItemKeys = ["NamedArmors", "NamedWeapons", "NamedHelmets", "NamedShields"];

        if (_lair == null)
        {
            return this.createNaiveNamedLoot(namedItemKeys);
        }

        if (::Math.rand(1, 100) > this.CampaignModifiers.LairFactionSpecificNamedLootChance)
        {
            this.logWrapper(format("Returning naive named loot tables for %s.", _lair.getName()));
            return this.createNaiveNamedLoot(namedItemKeys);
        }

        local namedLoot = [];

        foreach( key in namedItemKeys )
        {
            if (_lair.m[key + "List"] != null)
            {
                namedLoot.extend(_lair.m[key + "List"]);
            }
        }

        if (namedLoot.len() == 0)
        {
            this.logWrapper(format("%s has no non-empty named loot tables.", _lair.getName()));
            return this.createNaiveNamedLoot(namedItemKeys);
        }

        return namedLoot;
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
                this.logWrapper(format("depopulateLairNamedLoot removed %s from the inventory of lair %s.", item.getName(), _lair.getName()));
                break;
            }
        }
    }

    function findLairCandidates( _faction )
    {
        local lairs = [];

        if (_faction.getSettlements().len() == 0)
        {
            this.logWrapper("findLairCandidates was passed a viable faction as an argument, but this faction has no settlements at present.");
            return lairs;
        }

        this.logWrapper("Proceeding to lair candidate selection.");
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
                ::RPGR_Raids.logWrapper(format("%s is not an eligible lair.", _entity.getName()));
                return false;
            }

            return true;
        });

        return lairs;
    }

    function generateTooltipTableEntry( _id, _type, _icon, _text )
    {
        local tableEntry =
        {
            id = _id,
            type = _type,
            icon = _icon,
            text = _text
        }

        return tableEntry;
    }

    function getDescriptor( _valueToMatch, _referenceTable )
    {
        foreach( descriptor, value in _referenceTable )
        {
            if (value == _valueToMatch)
            {
                return descriptor;
            }
        }
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
        return _lair.getFlags().get("BaseNamedItemChance") + _lair.getResources() / 10;
    }

    function logWrapper( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError(format("[Raids] %s", _string));
            return;
        }

        if (!this.Mod.ModSettings.getSetting("VerboseLogging").getValue())
        {
            return;
        }

        ::logInfo(format("[Raids] %s", _string));
    }

    function initialiseCaravanParameters( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();
        local typeModifier = (_settlement.isMilitary() || _settlement.isSouthern()) ? 1 : 0;
        local sizeModifier = _settlement.getSize() >= 3 ? 1 : 0;
        local situationModifier = this.calculateSettlementSituationModifier(_settlement) > 0 ? 1 : 0;
        local distributions =
        {
            Supplies = 50,
            Trade = 100,
            Assortment = 20
        };
        flags.set("CaravanWealth", ::Math.min(this.CaravanWealthDescriptors.Abundant, ::Math.rand(1, 2) + typeModifier + sizeModifier + situationModifier));

        if (::Math.rand(1, 100) <= this.CampaignModifiers.CaravanNamedItemChance && flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Abundant && ::World.getTime().Days >= this.CampaignModifiers.ReinforcementThresholdDays)
        {
            flags.set("CaravanHasNamedItems", true);
        }

        local randomNumber = ::Math.rand(1, 100);
        local cargoType = (randomNumber <= distributions.Assortment || _settlement.getProduce().len() == 0) ? "Assortment" : randomNumber <= distributions.Supplies ? "Supplies" : "Trade";
        flags.set("CaravanCargo", this.CaravanCargoDescriptors[cargoType]);
        this.logWrapper(format("Rolled %i for caravan cargo assignment for caravan from %s of the newly assigned cargo type %s.", randomNumber, _settlement.getName(), this.getDescriptor(flags.get("CaravanCargo"), this.CaravanCargoDescriptors)));
        this.populateCaravanInventory(_caravan, _settlement);

        if (::Math.rand(1, 100) <= this.Mod.ModSettings.getSetting("CaravanReinforcementChance").getValue() || flags.get("CaravanWealth") >= this.CaravanWealthDescriptors.Plentiful)
        {
            this.reinforceCaravanTroops(_caravan, _settlement);
        }
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
        ::RPGR_Raids.logWrapper(format("%s are eligible for Vanguard status.", partyName));
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
            this.logWrapper(format("%s was found to be an active contract location, aborting.", lair.getName()));
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

    function isLairEligibleForProcedure( _lair, _procedure )
    {
        local agitationState = _lair.getFlags().get("Agitation");
        local lairName = _lair.getName();

        if (agitationState > this.AgitationDescriptors.Militant || agitationState < this.AgitationDescriptors.Relaxed)
        {
            this.logWrapper(format("Agitation for %s occupies an out-of-bounds value.", lairName), true);
            return false;
        }

        if (_procedure == this.Procedures.Increment && agitationState >= this.AgitationDescriptors.Militant)
        {
            this.logWrapper(format("Agitation for %s is capped, aborting procedure.", lairName));
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitationState <= this.AgitationDescriptors.Relaxed)
        {
            this.logWrapper(format("Agitation for %s is already at its minimum value, aborting procedure.", lairName));
            return false;
        }

        this.logWrapper(format("Lair %s is eligible for agitation state change procedures.", lairName));
        return true;
    }

    function isPartyViable( _flags )
    {
        return _flags.get("IsCaravan");
    }

    function isPlayerInProximityTo( _targetTile )
    {
        return ::World.State.getPlayer().getTile().getDistanceTo(_targetTile) <= this.CampaignModifiers.GlobalProximityTiles;
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

    function populateCaravanInventory( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();

        if (flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Light)
        {
            return;
        }

        if (flags.get("CaravanCargo") == this.CaravanCargoDescriptors.Assortment)
        {
            this.createNaivePartyLoot(_caravan);
            return;
        }

        local goods = this.createCaravanCargo(_caravan, _settlement);
        this.addToInventory(_caravan, goods, true);
    }

    function reinforceCaravanTroops( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();
        local wealth = flags.get("CaravanWealth");

        if (wealth == this.CaravanWealthDescriptors.Light)
        {
            return;
        }

        local currentTimeDays = ::World.getTime().Days;
        local timeModifier = ::Math.floor(currentTimeDays / this.CampaignModifiers.ReinforcementThresholdDays);
        local naiveIterations = ::Math.rand(1, wealth * 2) + timeModifier;
        local iterations = naiveIterations > this.CampaignModifiers.ReinforcementMaximumTroopOffset ? this.CampaignModifiers.ReinforcementMaximumTroopOffset : naiveIterations;
        local factionType = ::World.FactionManager.getFaction(_caravan.getFaction()).getType();
        local mundaneTroops = this.createCaravanTroops(wealth, factionType);

        for( local i = 0; i <= iterations; i = ++i )
        {
            ::Const.World.Common.addTroop(_caravan, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, true);
        }

        if (!(wealth == this.CaravanWealthDescriptors.Abundant && flags.get("CaravanHasNamedItems")))
        {
            return;
        }

        if (currentTimeDays < this.CampaignModifiers.ReinforcementThresholdDays)
        {
            return;
        }

        local eliteTroops = this.createEliteCaravanTroops(factionType);
        ::Const.World.Common.addTroop(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, true);
    }

    function repopulateLairNamedLoot( _lair )
    {
        local namedLootChance = this.getNamedLootChance(_lair);
        local iterations = 0;
        this.logWrapper(format("namedLootChance is %g for lair %s.", namedLootChance, _lair.getName()));

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
            this.logWrapper(format("Added item with filepath %s to the inventory of %s.", namedItem, _lair.getName()));
        }
    }

    function retrieveCaravanCargoIconPath( _cargoValue )
    {
        switch (_cargoValue)
        {
            case (this.CaravanCargoDescriptors.Unassorted):
                return "bag.png";

            case (this.CaravanCargoDescriptors.Assortment):
                return "asset_money.png";

            case(this.CaravanCargoDescriptors.Trade):
                return "money.png";

            case(this.CaravanCargoDescriptors.Supplies):
                return "asset_food.png"

            default:
                this.logWrapper("Invalid caravan cargo value, unable to retrieve icon.", true);
        }
    }

    function retrieveNamedCaravanCargo( _lootTable )
    {
        local namedCargo = this.createNamedLoot();
        local namedItem = ::new("scripts/items/" + namedCargo[::Math.rand(0, namedCargo.len() - 1)]);
        namedItem.onAddedToStash(null);
        this.logWrapper(format("Added %s to the loot table.", namedItem.getName()));
        _lootTable.push(namedItem);
    }


    function selectRandomPartyTemplate( _party, _partyList, _resources )
    {
        local troopsTemplate = [];
        local bailOut = 0;
        local maximumIterations = 10;

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
            this.logWrapper(format("Exceeded maximum iterations for troop assignment for party %s.", _party.getName()));
        }

        return troopsTemplate;
    }

    function setLairAgitation( _lair, _procedure )
    {
        if (!this.isLairEligibleForProcedure(_lair, _procedure))
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
                this.logWrapper("setLairAgitation was called with an invalid procedure value.", true);
                return;
        }

        flags.set("LastAgitationUpdate", ::World.getTime().Days);
        local baseResources = flags.get("BaseResources");
        local resourceModifier = -0.0006 * baseResources + 0.4;
        local agitationResourceOffset = resourceModifier * baseResources * (flags.get("Agitation") - 1) * (this.Mod.ModSettings.getSetting("AgitationResourceModifier").getValue() / 100.0);
        _lair.m.Resources = ::Math.floor(baseResources + agitationResourceOffset);
        this.logWrapper("Refreshing lair defender roster on agitation update.");
        _lair.createDefenders();
        _lair.setLootScaleBasedOnResources(_lair.getResources());

        if (_procedure != this.Procedures.Increment)
        {
            this.depopulateLairNamedLoot(_lair);
            return;
        }

        if (::Math.rand(1, 100) > this.CampaignModifiers.LairNamedLootRefreshChance && flags.get("Agitation") != this.AgitationDescriptors.Militant)
        {
            this.logWrapper(format("Skipping named loot refresh procedure within this agitation cycle for lair %s.", _lair.getName()));
            return;
        }

        this.repopulateLairNamedLoot(_lair);
    }

    function updateCombatStatistics( _flagStates )
    {
        local worldFlags = ::World.Statistics.getFlags();
        worldFlags.set("LastFoeWasVanguardParty", _flagStates[0]);
        worldFlags.set("LastFoeWasParty", _flagStates[1]);
    }

    function updateCumulativeLairAgitation( _lair )
    {
        local flags = _lair.getFlags();
        local lastUpdateTimeDays = flags.get("LastAgitationUpdate");

        if (lastUpdateTimeDays == false)
        {
            return;
        }

        local currentTimeDays = ::World.getTime().Days;
        local decayInterval = this.Mod.ModSettings.getSetting("AgitationDecayInterval").getValue();
        local timeDifference = currentTimeDays - lastUpdateTimeDays;

        if (timeDifference < decayInterval)
        {
            return;
        }

        this.logWrapper(format("Last agitation update occurred %i days ago.", timeDifference));
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
};

::mods_registerMod(::RPGR_Raids.ID, ::RPGR_Raids.Version, ::RPGR_Raids.Name);
::mods_queue(::RPGR_Raids.ID, "mod_msu(>=1.2.6)", function()
{
    ::RPGR_Raids.Mod <- ::MSU.Class.Mod(::RPGR_Raids.ID, ::RPGR_Raids.Version, ::RPGR_Raids.Name);

    local pageGeneral = ::RPGR_Raids.Mod.ModSettings.addPage("General");
    local pageLairs = ::RPGR_Raids.Mod.ModSettings.addPage("Lairs");
    local pageCaravans = ::RPGR_Raids.Mod.ModSettings.addPage("Caravans");

    local agitationDecayInterval = pageLairs.addRangeSetting("AgitationDecayInterval", 7, 1, 50, 1, "Agitation Decay Interval");
    agitationDecayInterval.setDescription("Determines the time interval in days after which a location's agitation value drops by one tier.");

    local agitationIncrementChance = pageLairs.addRangeSetting("AgitationIncrementChance", 100, 0, 100, 1, "Agitation Increment Chance");
    agitationIncrementChance.setDescription("Determines the chance for a location's agitation value to increase upon engagement with a roaming party, if within proximity.");

    local agitationResourceModifier = pageLairs.addRangeSetting("AgitationResourceModifier", 70, 50, 100, 10, "Agitation Resource Modifier");
    agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each agitation tier change. Higher percentage values result in greater resources, and therefore more powerful garrisoned troops and better loot.");

    local roamerScaleChance = pageLairs.addRangeSetting("RoamerScaleChance", 50, 1, 100, 1, "Roamer Scale Chance");
    roamerScaleChance.setDescription("Determines the percentage chance for hostile roaming and ambush parties spawning from lairs to scale in strength with respect to the originating lair's resource count. Does not affect beasts.");

    local roamerResourceModifier = pageLairs.addRangeSetting("RoamerResourceModifier", 70, 50, 100, 10, "Roamer Resource Modifier");
    roamerResourceModifier.setDescription("Controls how resource calculation is handled for roaming parties. Higher percentage values result in greater resources, and therefore more powerful roaming troops. Does nothing if roamer scale chance is set to zero.");

    local depopulateLairLootOnSpawn = pageLairs.addBooleanSetting("DepopulateLairLootOnSpawn", true, "Depopulate Lair Loot On Spawn");
    depopulateLairLootOnSpawn.setDescription("Determines whether Raids should depopulate newly spawned lairs of named loot. This is recommended to compensate for the additional named loot brought about by the introduction of agitation as a game mechanic.");

    local roamerScaleAgitationRequirement = pageLairs.addBooleanSetting("RoamerScaleAgitationRequirement", false, "Roamer Scale Agitation Requirement");
    roamerScaleAgitationRequirement.setDescription("Determines whether roamer scaling occurs for lairs with baseline agitation. Will result in stronger eligible roamer spawns on a game-wide basis.");

    local caravanReinforcementChance = pageCaravans.addRangeSetting("CaravanReinforcementChance", 100, 1, 100, 1, "Caravan Reinforcement Chance");
    caravanReinforcementChance.setDescription("Determines the percentage change for caravan troop count and composition reinforcement based on caravan wealth, and in special cases, cargo type. If certain conditions obtain, this will also result in the addition of special troops with powerful end-game gear to wealthy caravans, independent of player progression.");

    local handleSupplyCaravans = pageCaravans.addBooleanSetting("HandleSupplyCaravans", false, "Handle Supply Caravans");
    handleSupplyCaravans.setDescription("Determines whether Raids should handle supply caravans in the same manner as trading caravans, or if they should behave as in the base game.");

    local verboseLogging = pageGeneral.addBooleanSetting("VerboseLogging", true, "Verbose Logging"); // TODO: set this to false when done
    verboseLogging.setDescription("Enables verbose logging. Recommended for testing purposes only, as the volume of logged messages can make parsing the log more difficult for general use and debugging.");

    foreach( file in ::IO.enumerateFiles("mod_rpgr_raids/hooks") )
    {
        ::include(file);
    }
});