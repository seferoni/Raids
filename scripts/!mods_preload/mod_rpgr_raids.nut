::RPGR_Raids <-
{   // TODO: begin culling needlessly verbose logging when ready to ship
    // TODO: change assignment operators to new slot operators where applicable
    ID = "mod_rpgr_raids",
    Name = "RPG Rebalance - Raids",
    Version = "1.0.0",
    AgitationDescriptors =
    {
        Relaxed = 1,
        Cautious = 2,
        Vigilant = 3,
        Desperate = 4
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
        CaravanNamedItemChance = 50, // FIXME: this is inflated, revert to 5
        NamedItemChanceOnSpawn = 30,
        GlobalProximityTiles = 9
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    }

    function addToCaravanInventory( _caravan, _goodsPool )
    {
        local iterations = ::Math.rand(1, _caravan.getFlags().get("CaravanWealth") - 1);

        for( local i = 0; i != iterations; i = ++i )
        {
            local good = _goodsPool[::Math.rand(0, _goodsPool.len() - 1)];
            this.logWrapper("[Raids] Added item with filepath " + good + " to caravan inventory.");
            _caravan.addToInventory(good);
        }
    }

    function areCaravanFlagsInitialised( _flags )
    {
        return _flags.get("CaravanWealth") != false && _flags.get("CaravanCargo") != false;
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

        foreach( situation in synergisticSituations )
        {
            if (_settlement.getSituationByID(situation) != null)
            {
                modifier += smallestIncrement;
            }
        }

        foreach( situation in antagonisticSituations )
        {
            if (_settlement.getSituationByID(situation) != null)
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
        local actualProduce = produce.filter(function( index, value )
        {
            return value.find(descriptor) != null;
        });

        if (actualProduce.len() == 0)
        {
            this.logWrapper("[Raids] " + _settlement.getName() + " has no produce corresponding to caravan cargo type.");
            local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CaravanCargoDescriptors.Assortment : this.CaravanCargoDescriptors.Unassorted;
            flags.set("CaravanCargo", newCargoType);

            if (newCargoType == this.CaravanCargoDescriptors.Assortment)
            {
                this.createNaiveCaravanCargo(_caravan);
                return;
            }

            this.addToCaravanInventory(_caravan, produce);
            return;
        }

        this.addToCaravanInventory(_caravan, actualProduce);
    }

    function createNaiveCaravanCargo( _caravan )
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

        if (::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.OrientalCityState)
        {
            this.addToCaravanInventory(_caravan, southernGoods);
            return;
        }

        exclusionList.extend(southernGoods);
        local scriptFiles = ::IO.enumerateFiles("scripts/items/supplies");
        scriptFiles.extend(::IO.enumerateFiles("scripts/items/trade"));

        foreach( excludedFile in exclusionList )
        {
            local index = scriptFiles.find("scripts/items/" + excludedFile);

            if (index != null)
            {
                scriptFiles.remove(index);
            }
        }

        local goods = scriptFiles.map(function( stringPath )
        {
            return stringPath.slice(14);
        });

        this.addToCaravanInventory(_caravan, goods);
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
                ::Const.World.Spawn.Troops.Mercenary,
                ::Const.World.Spawn.Troops.MercenaryRanged
            ]);

            return troops;
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
        local namedItemKeys = ["NamedArmors", "NamedWeapons", "NamedHelmets", "NamedShields"]

        if (_lair == null)
        {
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

        if (::Math.rand(1, 100) <= namedLootChance)
        {
            return;
        }

        local garbage = [];
        local items = _lair.getLoot().getItems();

        foreach( item in items )
        {
            if (item.isItemType(::Const.Items.ItemType.Named))
            {
                garbage.push(item);
            }
        }

        foreach( item in garbage )
        {
            local index = items.find(item);
            items.remove(index);
            this.logWrapper("[Raids] Removed " + item.m.Name + " at index " + index + ".");
        }
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

    function getLairWithinProximityOf( _tile, _locationCandidates )
    {
        local lairs = _locationCandidates.filter(function( locationIndex, location )
        {
            return ::RPGR_Raids.isLocationEligible(location) && location.getTile().getDistanceTo(_tile) <= 1;
        });

        if (lairs.len() == 0)
        {
            return false;
        }

        return lairs[0];
    }

    function getNamedLootChance( _lair )
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

    function logWrapper( _string, _isError = false )
    {
        if (this.Mod.ModSettings.getSetting("VerboseLogging").getValue() == false)
        {
            return;
        }

        if (_isError)
        {
            ::logError(_string);
            return;
        }

        ::logInfo(_string);
    }

    function initialiseCaravanParameters( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();
        local typeModifier = (_settlement.isMilitary() || _settlement.isSouthern()) ? 1 : 0;
        local sizeModifier = _settlement.getSize() >= 3 ? 1 : 0;
        local situationModifier = this.calculateSettlementSituationModifier(_settlement) > 0 ? 1 : 0;
        local distributions =
        {
            Supplies = 35,
            Trade = 45,
            Assortment = 20
        }
        flags.set("CaravanWealth", ::Math.min(this.CaravanWealthDescriptors.Abundant, ::Math.rand(1, 2) + typeModifier + sizeModifier + situationModifier));

        if (::Math.rand(1, 100) <= this.CampaignModifiers.CaravanNamedItemChance && flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Abundant)
        {
            flags.set("CaravanHasNamedItems", true);
        }

        local randomNumber = ::Math.rand(1, 100);

        if (randomNumber <= distributions.Assortment || _settlement.getProduce().len() == 0)
        {
            flags.set("CaravanCargo", this.CaravanCargoDescriptors.Assortment);
        }
        else if (randomNumber <= distributions.Supplies)
        {
            flags.set("CaravanCargo", this.CaravanCargoDescriptors.Supplies);
        }
        else
        {
            flags.set("CaravanCargo", this.CaravanCargoDescriptors.Trade);
        }

        this.populateCaravanInventory(_caravan, _settlement);
        this.reinforceCaravanTroops(_caravan, _settlement);
    }

    function isFactionViable( _faction )
    {
        if (_faction == null)
        {
            return false;
        }

        local exclusionList =
        [
            ::Const.FactionType.Beasts,
            ::Const.FactionType.Player,
            ::Const.FactionType.Settlement,
            ::Const.FactionType.NobleHouse,
            ::Const.FactionType.OrientalCityState
        ];
        local factionType = _faction.getType();

        foreach( excludedFaction in exclusionList )
        {
            if (factionType == excludedFaction)
            {
                return false;
            }
        }

        return true;
    }

    function isLocationEligible( _locationType )
    {
        return _locationType == ::Const.World.LocationType.Lair || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Mobile);
    }

    function isLairEligibleForProcedure( _lair, _procedure )
    {
        local agitationState = _lair.getFlags().get("Agitation");

        if (_procedure == this.Procedures.Increment && agitationState >= this.AgitationDescriptors.Desperate)
        {
            this.logWrapper("[Raids] Agitation for " + _lair.getName() + " is capped, aborting procedure.");
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitationState <= this.AgitationDescriptors.Relaxed)
        {
            return false;
        }

        this.logWrapper("[Raids] Lair " + _lair.getName() + " is eligible for agitation state change procedures.");
        return true;
    }

    function isPartyEligible( _flags )
    {
        return _flags.get("IsCaravan");
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
            this.logWrapper("[Raids] " +_lair.getName() + " was found to be an active contract location, aborting.");
            return true;
        }

        return false;
    }

    function isPlayerInProximityTo( _targetTile )
    {
        return ::World.State.getPlayer().getTile().getDistanceTo(_targetTile) <= this.CampaignModifiers.GlobalProximityTiles;
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
            this.createNaiveCaravanCargo(_caravan);
            return;
        }

        this.createCaravanCargo(_caravan, _settlement);
    }

    function reinforceCaravanTroops( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();
        local wealth = flags.get("CaravanWealth");

        if (wealth == this.CaravanWealthDescriptors.Light)
        {
            return;
        }

        local iterations = ::Math.rand(1, wealth * 2);
        local factionType = ::World.FactionManager.getFaction(_caravan.getFaction()).getType();
        local mundaneTroops = this.createCaravanTroops(wealth, factionType);

        for( local i = 0; i != iterations; i = ++i )
        {
            ::Const.World.Common.addTroop(_caravan, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, true);
        }

        if (!(wealth == this.CaravanWealthDescriptors.Abundant && flags.get("CaravanHasNamedItems")))
        {
            return;
        }

        local eliteTroops = this.createEliteCaravanTroops(factionType);
        ::Const.World.Common.addTroop(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, true);
    }

    function repopulateLairNamedLoot( _lair )
    {
        local namedLootChance = this.getNamedLootChance(_lair);
        this.logWrapper("[Raids] namedLootChance is " + namedLootChance + " for lair " + _lair.getName());

        if (::Math.rand(1, 100) > namedLootChance)
        {
            return;
        }

        local namedLoot = this.createNamedLoot(_lair);
        _lair.m.Loot.add(::new("scripts/items/" + namedLoot[::Math.rand(0, namedLoot.len() - 1)]));
    }

    function retrieveCaravanCargoIconPath( _cargoValue )
    {
        local iconPath = null;

        switch (_cargoValue)
        {
            case (this.CaravanCargoDescriptors.Unassorted):
                iconPath = "bag.png";
                break;

            case (this.CaravanCargoDescriptors.Assortment):
                iconPath = "asset_money.png";
                break;

            case(this.CaravanCargoDescriptors.Trade):
                iconPath = "money.png";
                break;

            case(this.CaravanCargoDescriptors.Supplies):
                iconPath = "asset_food.png"
                break;

            default:
                ::logError("[Raids] Invalid caravan cargo value, unable to retrieve icon.");
        }

        return iconPath;
    }

    function retrieveNamedCaravanCargo( _lootTable )
    {
        local namedCargo = this.createNamedLoot();
        local namedItem = ::new("scripts/items/" + namedCargo[::Math.rand(0, namedCargo.len() - 1)]);
        namedItem.onAddedToStash(null);
        this.logWrapper("Added " + namedItem.getName() + " to the loot table.");
        _lootTable.push(namedItem);
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
                this.repopulateLairNamedLoot(_lair);
                break;

            case (this.Procedures.Decrement):
                flags.increment("Agitation", -1);
                this.depopulateLairNamedLoot(_lair);
                break;

            case (this.Procedures.Reset):
                flags.set("Agitation", this.AgitationDescriptors.Relaxed);
                this.depopulateLairNamedLoot(_lair);
                break;

            default:
                ::logError("[Raids] setLairAgitation was called with an invalid procedure value.");
        }

        flags.set("LastAgitationUpdate", ::World.getTime().Days);
        _lair.m.Resources = flags.get("Agitation") == this.AgitationDescriptors.Relaxed ? flags.get("BaseResources") : ::Math.floor(flags.get("BaseResources") * flags.get("Agitation") * this.Mod.ModSettings.getSetting("AgitationResourceModifier").getValue());
        _lair.setLootScaleBasedOnResources(_lair.getResources());
    }

    function updateCumulativeLairAgitation( _lair )
    {   // TODO: test this
        local flags = _lair.getFlags();
        local lastUpdateTimeDays = flags.get("LastAgitationUpdate");

        if (lastUpdateTimeDays == false)
        {
            return;
        }

        local currentTimeDays = ::World.getTime().Days;
        local decayInterval = this.Mod.ModSettings.getSetting("AgitationDecayInterval").getValue();
        local difference = currentTimeDays - lastUpdateTime;

        if (difference < decayInterval)
        {
            return;
        }

        this.logWrapper("[Raids] Difference is  " + difference + " decayInterval is " + decayInterval); // TODO: remove this
        local decrementIterations = ::Math.floor(difference / decayInterval);

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
{ // TODO: consider additional configurability
    ::RPGR_Raids.Mod <- ::MSU.Class.Mod(::RPGR_Raids.ID, ::RPGR_Raids.Version, ::RPGR_Raids.Name);

    local pageGeneral = ::RPGR_Raids.Mod.ModSettings.addPage("General");

    local agitationDecayInterval = pageGeneral.addRangeSetting("AgitationDecayInterval", 7, 1, 14, 1, "Agitation Decay Interval");
    agitationDecayInterval.setDescription("Determines the time interval in days after which a location's agitation value drops by one tier.");

    local agitationIncrementChance = pageGeneral.addRangeSetting("AgitationIncrementChance", 100, 0, 100, 1, "Agitation Increment Chance"); // TODO: this should be default 50 when raids ship
    agitationIncrementChance.setDescription("Determines the chance for a location's agitation value to increase by one tier upon victory against a roaming party, if within proximity.");

    local agitationResourceModifier = pageGeneral.addRangeSetting("AgitationResourceModifier", 0.7, 0.0, 1.0, 0.1, "Agitation Resource Modifier"); // FIXME: Floating number display bug
    agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each agitation tier change. Higher values result in greater resources, and therefore more powerful garrisoned troops and better loot.");

    local depopulateLairLootOnSpawn = pageGeneral.addBooleanSetting("DepopulateLairLootOnSpawn", false, "Depopulate Lair Loot On Spawn");
    depopulateLairLootOnSpawn.setDescription("Determines whether Raids should depopulate newly spawned lairs of named loot to compensate for broadly higher named loot frequency with the introduction of agitation as a game mechanic.");

    local verboseLogging = pageGeneral.addBooleanSetting("VerboseLogging", true, "Verbose Logging"); // TODO: set this to false when done
    verboseLogging.setDescription("Enables verbose logging. Recommended for testing purposes only, as the volume of logged messages can make parsing the log more difficult for general use and debugging.");

    foreach( file in ::IO.enumerateFiles("mod_rpgr_raids/hooks") )
    {
        ::include(file);
    }
});