local Raids = ::RPGR_Raids;
Raids.Caravans <-
{
    AntagonisticSituations =
    [
        "situation.ambushed_trade_routes",
        "situation.disappearing_villagers",
        "situation.greenskins",
        "situation.raided"
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
    }
    Parameters =
    {
        NamedItemChance = 50, // FIXME: this is inflated, revert to 5
        MaximumTroopOffset = 7,
        ReinforcementThresholdDays = 1 // FIXME: this is deflated, revert to 50
    },
    SynergisticSituations =
    [
        "situation.well_supplied",
        "situation.good_harvest",
        "situation.safe_roads"
    ],
    WealthDescriptors =
    {
        Meager = 1,
        Moderate = 2,
        Plentiful = 3,
        Abundant = 4
    }

    function addNamedCargo( _lootTable )
    {
        local namedCargo = Raids.Shared.createNamedLoot(),
        namedItem = ::new("scripts/items/" + namedCargo[::Math.rand(0, namedCargo.len() - 1)]);
        namedItem.onAddedToStash(null);
        _lootTable.push(namedItem);
        Raids.Standard.log(format("Added %s to the loot table.", namedItem.getName()));
    }

    function areFlagsInitialised( _flags )
    {
        return _flags.get("CaravanWealth") != false && _flags.get("CaravanCargo") != false;
    }

    function createCaravanCargo( _caravan, _settlement )
    {
        local flags = _caravan.getFlags(), produce = _settlement.getProduce(),
        descriptor = Raids.Standard.getDescriptor(flags.get("CaravanCargo"), this.CargoDescriptors).tolower(),
        actualProduce = produce.filter(@(_index,_value) _value.find(descriptor) != null);

        if (actualProduce.len() != 0)
        {
            return actualProduce;
        }

        Raids.Standard.log(format("%s has no produce corresponding to caravan cargo type.", _settlement.getName()));
        local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CargoDescriptors.Assortment : this.CargoDescriptors.Unassorted;
        flags.set("CaravanCargo", newCargoType);

        if (newCargoType == this.CargoDescriptors.Assortment)
        {
            return Raids.Shared.createNaivePartyLoot(_caravan);
        }

        return produce;
    }

    function createCaravanTroops( _wealth, _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([::Const.World.Spawn.Troops.Billman, ::Const.World.Spawn.Troops.Footman, ::Const.World.Spawn.Troops.Arbalester, ::Const.World.Spawn.Troops.ArmoredWardog]);
            return troops;
        }

        troops.push(::Const.World.Spawn.Troops.MercenaryLOW);

        if (::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
        {
            troops.extend([::Const.World.Spawn.Troops.Mercenary, ::Const.World.Spawn.Troops.MercenaryRanged]);
        }

        if (_factionType == ::Const.FactionType.OrientalCityState)
        {
            troops.extend([::Const.World.Spawn.Troops.Conscript, ::Const.World.Spawn.Troops.ConscriptPolearm]);
            return troops;
        }

        troops.extend([::Const.World.Spawn.Troops.CaravanHand, ::Const.World.Spawn.Troops.CaravanGuard]);
        return troops;
    }

    function createEliteCaravanTroops( _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([::Const.World.Spawn.Troops.MasterArcher, ::Const.World.Spawn.Troops.Greatsword, ::Const.World.Spawn.Troops.Knight]);
        }
        else
        {
            troops.extend([::Const.World.Spawn.Troops.HedgeKnight, ::Const.World.Spawn.Troops.Swordmaster]);
        }

        return troops;
    }

    function getCargoIcon( _cargoValue )
    {
        switch (_cargoValue)
        {
            case (this.CargoDescriptors.Unassorted): return "bag.png";
            case (this.CargoDescriptors.Assortment): return "asset_money.png";
            case (this.CargoDescriptors.Trade): return "money.png";
            case (this.CargoDescriptors.Supplies): return "asset_food.png"
            default: Raids.Standard.log("Invalid caravan cargo value, unable to retrieve icon.", true);
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
        local flags = _caravan.getFlags(), randomNumber = ::Math.rand(1, 100), diceRoll = @(_value) randomNumber <= _value;
        this.setCaravanWealth(_caravan, _settlement);
        this.setCaravanCargo(_caravan, _settlement);
        this.populateInventory(_caravan, _settlement);

        if (flags.get("CaravanWealth") < this.WealthDescriptors.Plentiful)
        {
            return;
        }

        if (!diceRoll(Raids.Standard.getSetting("CaravanReinforcementChance")))
        {
            return;
        }

        if (diceRoll(this.Parameters.NamedItemChance) && flags.get("CaravanWealth") == this.WealthDescriptors.Abundant && ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
        {
            flags.set("CaravanHasNamedItems", true);
        }

        this.reinforceTroops(_caravan, _settlement);
    }

    function isPartyViable( _party )
    {
        return _party.getFlags().get("IsCaravan");
    }

    function populateInventory( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();

        if (flags.get("CaravanWealth") == this.WealthDescriptors.Meager)
        {
            return;
        }

        if (flags.get("CaravanCargo") == this.CargoDescriptors.Assortment)
        {
            Raids.Shared.createNaivePartyLoot(_caravan);
            return;
        }

        Raids.Shared.addToInventory(_caravan, this.createCaravanCargo(_caravan, _settlement));
    }

    function reinforceTroops( _caravan, _settlement )
    {
        local flags = _caravan.getFlags(), wealth = flags.get("CaravanWealth");

        if (wealth == this.WealthDescriptors.Meager)
        {
            return;
        }

        local iterations = this.getReinforcementCount(wealth),
        factionType = ::World.FactionManager.getFaction(_caravan.getFaction()).getType(),
        mundaneTroops = this.createCaravanTroops(wealth, factionType);

        for( local i = 0; i <= iterations; i = ++i )
        {
            ::Const.World.Common.addTroop(_caravan, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, true);
        }

        if (!(wealth == this.WealthDescriptors.Abundant && flags.get("CaravanHasNamedItems")))
        {
            return;
        }

        if (currentTimeDays < this.Parameters.ReinforcementThresholdDays)
        {
            return;
        }

        local eliteTroops = this.createEliteCaravanTroops(factionType);
        ::Const.World.Common.addTroop(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, true);
    }

    function setCaravanWealth( _caravan, _settlement )
    {
        local caravanCargo = ::Math.rand(1, 2);

        if (_settlement.isMilitary() || _settlement.isSouthern())
        {
            caravanCargo += 1;
        }

        if (_settlement.getSize() >= 3)
        {
            caravanCargo += 1;
        }

        caravanCargo += ::Math.ceil(this.getSituationModifier(_settlement))
        _caravan.getFlags().set("CaravanWealth", ::Math.min(this.WealthDescriptors.Abundant, caravanCargo));
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

        _caravan.getFlags().set("CaravanCargo", cargoType);
    }
};