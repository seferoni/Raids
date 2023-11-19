local Raids = ::RPGR_Raids;
Raids.Caravans <-
{
    AntagonisticSituations =
    [
        "situation.ambushed_trade_routes",
        "situation.draught",
        "situation.greenskins",
        "situation.mine_cavein",
        "situation.moving_sands",
        "situation.raided",
        "situation.short_on_food",
        "situation.sickness",
        "situation.slave_revolt",
        "situation.snow_storms",
        "situation.warehouse_burned_down"
    ],
    CargoDescriptors =
    {
        Supplies = 1,
        Trade = 2,
        Assortment = 3,
        Unassorted = 4
    },
    CargoDistribution =
    {
        Supplies = 50,
        Trade = 100,
        Assortment = 20
    },
    ExcludedGoods = 
    [
        "supplies/food_item",
        "supplies/money_item",
        "trade/trading_good_item",
        "supplies/strange_meat_item",
        "supplies/fermented_unhold_heart_item",
        "supplies/black_marsh_stew_item"
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
        MaximumTroopOffset = 7,
        NamedItemChance = 100, // TODO: inflated, revert to 5
        ReinforcementThresholdDays = 1, // TODO: inflated, revert to 50
        SupplyCaravanDocumentChanceOffset = 25 
    },
    SouthernGoods = 
    [
        "supplies/dates_item",
        "supplies/rice_item",
        "trade/silk_item",
        "trade/spices_item",
        "trade/incense_item"
    ],
    SynergisticSituations =
    [
        "situation.bread_and_games",
        "situation.full_nets",
        "situation.good_harvest",
        "situation.rich_veins",
        "situation.safe_roads",
        "situation.seasonal_fair",
        "situation.well_supplied"
    ],
    WealthDescriptors =
    {
        Meager = 1,
        Moderate = 2,
        Plentiful = 3,
        Abundant = 4
    }

    function addToInventory( _caravan, _goodsPool )
    {
        local iterations = Raids.Standard.getFlag("CaravanWealth", _caravan) - 1;
        
        for( local i = 0; i < iterations; i++ )
        {
            _caravan.addToInventory(_goodsPool[::Math.rand(0, _goodsPool.len() - 1)]);
        }
    }

    function addNamedCargo( _lootTable )
    {
        local namedCargo = this.createNamedLoot(),
        namedItem = ::new(format("scripts/items/%s", namedCargo[::Math.rand(0, namedCargo.len() - 1)]));
        namedItem.onAddedToStash(null);
        _lootTable.push(namedItem);
    }

    function isPartyInitialised( _party )
    {
        return Raids.Standard.getFlag("CaravanWealth", _party) != false && Raids.Standard.getFlag("CaravanCargo", _party) != false;
    }

    function createCaravanCargo( _caravan, _settlement )
    {
        local produce = _settlement.getProduce(),
        descriptor = Raids.Standard.getDescriptor(Raids.Standard.getFlag("CaravanCargo", _caravan), this.CargoDescriptors).tolower(),
        actualProduce = produce.filter(@(_index,_value) _value.find(descriptor) != null);

        if (actualProduce.len() != 0)
        {
            return actualProduce;
        }

        local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CargoDescriptors.Assortment : this.CargoDescriptors.Unassorted;
        Raids.Standard.setFlag("CaravanCargo", newCargoType, _caravan);

        if (newCargoType == this.CargoDescriptors.Assortment)
        {
            return this.createNaiveCaravanCargo(_caravan);
        }

        return produce;
    }

    function createCaravanTroops( _wealth, _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([::Const.World.Spawn.Troops.Arbalester, ::Const.World.Spawn.Troops.Billman, ::Const.World.Spawn.Troops.Footman]);
            return troops;
        }

        troops.push(::Const.World.Spawn.Troops.MercenaryLOW);

        if (::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
        {
            troops.extend([::Const.World.Spawn.Troops.Mercenary, ::Const.World.Spawn.Troops.MercenaryRanged]);
        }

        if (_factionType == ::Const.FactionType.OrientalCityState)
        {
            troops.extend([::Const.World.Spawn.Troops.Conscript, ::Const.World.Spawn.Troops.ConscriptPolearm, ::Const.World.Spawn.Troops.Gunner]);
            return troops;
        }

        troops.extend([::Const.World.Spawn.Troops.CaravanGuard, ::Const.World.Spawn.Troops.CaravanHand]);
        return troops;
    }

    function createEliteCaravanTroops( _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([::Const.World.Spawn.Troops.Greatsword, ::Const.World.Spawn.Troops.Knight, ::Const.World.Spawn.Troops.Sergeant]);
            return troops;
        }

        if (_factionType == ::Const.FactionType.OrientalCityState)
        {
            troops.extend([::Const.World.Spawn.Troops.Assassin, ::Const.World.Spawn.Troops.DesertDevil, ::Const.World.Spawn.Troops.DesertStalker]);
            return troops;
        }

        troops.extend([::Const.World.Spawn.Troops.HedgeKnight, ::Const.World.Spawn.Troops.MasterArcher, ::Const.World.Spawn.Troops.Swordmaster]);
        return troops;
    }

    function createNaiveCaravanCargo( _caravan )
    {
        if (::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.OrientalCityState)
        {
            return this.SouthernGoods;
        }
        
        local exclusionList = clone this.ExcludedGoods;
        exclusionList.extend(this.SouthernGoods);
        local scriptFiles = ::IO.enumerateFiles("scripts/items/trade");
        scriptFiles.extend(::IO.enumerateFiles("scripts/items/supplies"));

        foreach( filePath in exclusionList )
        {
            local index = scriptFiles.find(format("scripts/items/%s", filePath));
            if (index != null) scriptFiles.remove(index);
        }

        local culledString = "scripts/items/",
        goods = scriptFiles.map(@(_stringPath) _stringPath.slice(culledString.len()));
        return goods;
    }

    function createNamedLoot()
    {
        local namedLoot = [];

        foreach( key in this.NamedItemKeys )
        {
            namedLoot.extend(::Const.Items[key]);
        }

        return namedLoot;
    }

    function getTooltipEntries( _caravan )
    {
        local cargoEntry = {id = 2, type = "hint"}, wealthEntry = clone cargoEntry,
        caravanWealth = Raids.Standard.getFlag("CaravanWealth", _caravan), caravanCargo = Raids.Standard.getFlag("CaravanCargo", _caravan);
        cargoEntry.icon <- format("ui/icons/%s", this.getCargoIcon(caravanCargo));
        cargoEntry.text <- format("%s", Raids.Standard.getDescriptor(caravanCargo, this.CargoDescriptors));
        wealthEntry.icon <- "ui/icons/money2.png";
        wealthEntry.text <- format("%s (%i)", Raids.Standard.getDescriptor(caravanWealth, this.WealthDescriptors), caravanWealth);

        if (!Raids.Standard.getFlag("CaravanHasNamedItems", _caravan))
        {
            return [cargoEntry, wealthEntry];
        }

        local famedItemEntry = clone cargoEntry;
        famedItemEntry.icon = "ui/icons/special.png";
        famedItemEntry.text = "Famed";
        return [cargoEntry, wealthEntry, famedItemEntry];
    }

    function getCargoIcon( _cargoValue )
    {
        switch (_cargoValue)
        {
            case (this.CargoDescriptors.Unassorted): return "bag.png";
            case (this.CargoDescriptors.Assortment): return "asset_money.png";
            case (this.CargoDescriptors.Trade): return "money.png";
            case (this.CargoDescriptors.Supplies): return "asset_food.png"
        }
    }

    function getReinforcementCount( _caravanWealth )
    {
        local timeModifier = ::Math.floor(::World.getTime().Days / this.Parameters.ReinforcementThresholdDays),
        naiveIterations = ::Math.rand(1, _caravanWealth * 2) + timeModifier;
        return ::Math.min(this.Parameters.MaximumTroopOffset, naiveIterations);
    }

    function getSituationModifier( _settlement )
    {
        local modifier = 0, smallestIncrement = 1.0,
        settlementSituations = _settlement.getSituations().map(@(_situation) _situation.getID());

        foreach( situation in settlementSituations )
        {
            if (this.SynergisticSituations.find(situation) != null)
            {
                modifier += smallestIncrement;
            }
            else if (this.AntagonisticSituations.find(situation) != null)
            {
                modifier -= smallestIncrement;
            }
        }

        return ::Math.max(0, modifier);
    }

    function initialiseCaravanParameters( _caravan, _settlement )
    {
        local randomNumber = ::Math.rand(1, 100),
        diceRoll = @(_value) randomNumber <= _value;
        this.setCaravanWealth(_caravan, _settlement);
        this.setCaravanCargo(_caravan, _settlement);
        this.populateInventory(_caravan, _settlement);

        if (Raids.Standard.getFlag("CaravanWealth", _caravan) < this.WealthDescriptors.Plentiful)
        {
            return;
        }

        if (!diceRoll(Raids.Standard.getSetting("CaravanReinforcementChance")))
        {
            return;
        }

        if (diceRoll(this.Parameters.NamedItemChance) && Raids.Standard.getFlag("CaravanWealth", _caravan) == this.WealthDescriptors.Abundant && ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
        {
            Raids.Standard.setFlag("CaravanHasNamedItems", true, _caravan);
        }

        this.reinforceTroops(_caravan, _settlement);
    }

    function isPartyViable( _party )
    {
        return Raids.Standard.getFlag("IsCaravan", _party);
    }

    function populateInventory( _caravan, _settlement )
    {
        if (Raids.Standard.getFlag("CaravanWealth", _caravan) == this.WealthDescriptors.Meager)
        {
            return;
        }

        if (Raids.Standard.getFlag("CaravanCargo", _caravan) == this.CargoDescriptors.Assortment)
        {
            this.addToInventory(_caravan, this.createNaiveCaravanCargo(_caravan));
            return;
        }

        this.addToInventory(_caravan, this.createCaravanCargo(_caravan, _settlement));
        local documentChance = Raids.Standard.getSetting("OfficialDocumentDropChance");

        if (::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.NobleHouse)
        {
            documentChance += Raids.Edicts.Internal.SupplyCaravanDocumentChanceOffset;
        }

        if (::Math.rand(1, 100) > documentChance)
        {
            return;
        }

        _caravan.addToInventory("special/official_document_item");
    }

    function reinforceTroops( _caravan, _settlement )
    {
        local wealth = Raids.Standard.getFlag("CaravanWealth", _caravan);

        if (wealth == this.WealthDescriptors.Meager)
        {
            return;
        }

        local iterations = this.getReinforcementCount(wealth),
        factionType = ::World.FactionManager.getFaction(_caravan.getFaction()).getType(),
        mundaneTroops = this.createCaravanTroops(wealth, factionType);

        for( local i = 0; i < iterations; i++ )
        {
            ::Const.World.Common.addTroop(_caravan, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, true);
        }

        if (!(wealth == this.WealthDescriptors.Abundant && Raids.Standard.getFlag("CaravanHasNamedItems", _caravan)))
        {
            return;
        }

        if (::World.getTime().Days < this.Parameters.ReinforcementThresholdDays)
        {
            return;
        }

        local eliteTroops = this.createEliteCaravanTroops(factionType);
        ::Const.World.Common.addTroop(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, true);
    }

    function setCaravanWealth( _caravan, _settlement )
    {
        local caravanWealth = ::Math.rand(1, 2);

        if (_settlement.isMilitary() || _settlement.isSouthern())
        {
            caravanWealth += 1;
        }

        if (_settlement.getSize() >= 3)
        {
            caravanWealth += 1;
        }

        caravanWealth += ::Math.ceil(this.getSituationModifier(_settlement));
        Raids.Standard.setFlag("CaravanWealth", ::Math.min(this.WealthDescriptors.Abundant, caravanWealth), _caravan);
    }

    function setCaravanCargo( _caravan, _settlement )
    {
        local randomNumber = ::Math.rand(1, 100), diceRoll = @(_value) randomNumber <= _value,
        cargoType = this.CargoDescriptors.Trade;

        if (diceRoll(this.CargoDistribution.Assortment) || _settlement.getProduce().len() == 0)
        {
            cargoType = this.CargoDescriptors.Assortment;
        }
        else if (diceRoll(this.CargoDistribution.Supplies))
        {
            cargoType = this.CargoDescriptors.Supplies;
        }

        Raids.Standard.setFlag("CaravanCargo", cargoType, _caravan);
    }
};