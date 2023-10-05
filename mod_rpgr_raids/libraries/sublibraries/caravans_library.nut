local Raids = ::RPGR_Raids;
Raids.Caravans <-
{
    CargoDescriptors =
    {
        Supplies = 1,
        Trade = 2,
        Assortment = 3,
        Unassorted = 4
    },
    Parameters =
    {
        NamedItemChance = 50, // FIXME: this is inflated, revert to 5
        MaximumTroopOffset = 7,
        ReinforcementThresholdDays = 1 // FIXME: this is deflated, revert to 50
    },
    WealthDescriptors =
    {
        Light = 1, // TODO: revise this
        Moderate = 2,
        Plentiful = 3,
        Abundant = 4
    }

    function addNamedCargo( _lootTable )
    {
        local namedCargo = Raids.Shared.createNamedLoot(), namedItem = ::new("scripts/items/" + namedCargo[::Math.rand(0, namedCargo.len() - 1)]);
        namedItem.onAddedToStash(null);
        Raids.Standard.log(format("Added %s to the loot table.", namedItem.getName()));
        _lootTable.push(namedItem);
    }

    function areFlagsInitialised( _flags )
    {
        return _flags.get("CaravanWealth") != false && _flags.get("CaravanCargo") != false;
    }

    function createCaravanCargo( _caravan, _settlement )
    {
        local produce = _settlement.getProduce(), flags = _caravan.getFlags(),
        descriptor = Raids.Standard.getDescriptor(flags.get("CaravanCargo"), this.CargoDescriptors).tolower(),
        actualProduce = produce.filter(@(_index,_value) _value.find(descriptor) != null);

        if (actualProduce.len() == 0)
        {
            Raids.Standard.log(format("%s has no produce corresponding to caravan cargo type.", _settlement.getName()));
            local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CargoDescriptors.Assortment : this.CargoDescriptors.Unassorted;
            flags.set("CaravanCargo", newCargoType);

            if (newCargoType == this.CargoDescriptors.Assortment)
            {
                return Raids.Shared.createNaivePartyLoot(_caravan);
            }

            return produce;
        }

        return actualProduce;
    }

    function createCaravanTroops( _wealth, _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([::Const.World.Spawn.Troops.Billman, ::Const.World.Spawn.Troops.Footman, ::Const.World.Spawn.Troops.Arbalester, ::Const.World.Spawn.Troops.ArmoredWardog]);
            return troops;
        }

        if (_wealth >= this.WealthDescriptors.Plentiful)
        {
            troops.push(::Const.World.Spawn.Troops.MercenaryLOW);

            if (::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
            {
                troops.extend([::Const.World.Spawn.Troops.Mercenary, ::Const.World.Spawn.Troops.MercenaryRanged]);
            }
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
            return troops;
        }

        troops.extend([::Const.World.Spawn.Troops.HedgeKnight, ::Const.World.Spawn.Troops.Swordmaster]);
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

    function getSituationModifier( _settlement )
    {
        local modifier = 0, smallestIncrement = 1.0,
        synergisticSituations = ["situation.well_supplied", "situation.good_harvest", "situation.safe_roads"],
        antagonisticSituations = ["situation.ambushed_trade_routes", "situation.disappearing_villagers", "situation.greenskins", "situation.raided"],
        settlementSituations = _settlement.getSituations().map(@(_situation) _situation.getID());

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

    function initialiseCaravanParameters( _caravan, _settlement )
    {
        local flags = _caravan.getFlags(),
        typeModifier = (_settlement.isMilitary() || _settlement.isSouthern()) ? 1 : 0,
        sizeModifier = _settlement.getSize() >= 3 ? 1 : 0,
        situationModifier = this.getSituationModifier(_settlement) > 0 ? 1 : 0,
        distributions = {Supplies = 50, Trade = 100, Assortment = 20};
        flags.set("CaravanWealth", ::Math.min(this.WealthDescriptors.Abundant, ::Math.rand(1, 2) + typeModifier + sizeModifier + situationModifier));

        if (::Math.rand(1, 100) <= this.Parameters.NamedItemChance && flags.get("CaravanWealth") == this.WealthDescriptors.Abundant && ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
        {
            flags.set("CaravanHasNamedItems", true);
        }

        local randomNumber = ::Math.rand(1, 100),
        cargoType = (randomNumber <= distributions.Assortment || _settlement.getProduce().len() == 0) ? "Assortment" : randomNumber <= distributions.Supplies ? "Supplies" : "Trade";
        flags.set("CaravanCargo", this.CargoDescriptors[cargoType]);
        Raids.Standard.log(format("Rolled %i for caravan cargo assignment for caravan from %s of the newly assigned cargo type %s.", randomNumber, _settlement.getName(), Raids.Standard.getDescriptor(flags.get("CaravanCargo"), this.CargoDescriptors)));
        this.populateInventory(_caravan, _settlement);

        if (::Math.rand(1, 100) <= Raids.Standard.getSetting("CaravanReinforcementChance") || flags.get("CaravanWealth") >= this.WealthDescriptors.Plentiful)
        {
            this.reinforceTroops(_caravan, _settlement);
        }
    }

    function isPartyViable( _party )
    {
        return _party.getFlags().get("IsCaravan");
    }

    function populateInventory( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();

        if (flags.get("CaravanWealth") == this.WealthDescriptors.Light)
        {
            return;
        }

        if (flags.get("CaravanCargo") == this.CargoDescriptors.Assortment)
        {
            Raids.Shared.createNaivePartyLoot(_caravan);
            return;
        }

        local goods = this.createCaravanCargo(_caravan, _settlement);
        this.addToInventory(_caravan, goods, true);
    }

    function reinforceTroops( _caravan, _settlement )
    {
        local flags = _caravan.getFlags(), wealth = flags.get("CaravanWealth");

        if (wealth == this.WealthDescriptors.Light)
        {
            return;
        }

        local currentTimeDays = ::World.getTime().Days, timeModifier = ::Math.floor(currentTimeDays / this.Parameters.ReinforcementThresholdDays);
        naiveIterations = ::Math.rand(1, wealth * 2) + timeModifier,
        iterations = naiveIterations > this.Parameters.MaximumTroopOffset ? this.Parameters.MaximumTroopOffset : naiveIterations,
        factionType = ::World.FactionManager.getFaction(_caravan.getFaction()).getType(), mundaneTroops = this.createCaravanTroops(wealth, factionType);

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
};