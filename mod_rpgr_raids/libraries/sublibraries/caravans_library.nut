::RPGR_Raids.Caravans <-
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

    function areCaravanFlagsInitialised( _flags )
    {
        return _flags.get("CaravanWealth") != false && _flags.get("CaravanCargo") != false;
    }

    function calculateSettlementSituationModifier( _settlement )
    {
        local modifier = 0, smallestIncrement = 1.0;
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
        local settlementSituations = _settlement.getSituations().map(@(_situation) _situation.getID());

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
        local actualProduce = produce.filter(@(_index,_value) _value.find(descriptor) != null);

        if (actualProduce.len() == 0)
        {
            this.log(format("%s has no produce corresponding to caravan cargo type.", _settlement.getName()));
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

            if (::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
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

        if (::Math.rand(1, 100) <= this.Parameters.CaravanNamedItemChance && flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Abundant && ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
        {
            flags.set("CaravanHasNamedItems", true);
        }

        local randomNumber = ::Math.rand(1, 100);
        local cargoType = (randomNumber <= distributions.Assortment || _settlement.getProduce().len() == 0) ? "Assortment" : randomNumber <= distributions.Supplies ? "Supplies" : "Trade";
        flags.set("CaravanCargo", this.CaravanCargoDescriptors[cargoType]);
        this.log(format("Rolled %i for caravan cargo assignment for caravan from %s of the newly assigned cargo type %s.", randomNumber, _settlement.getName(), this.getDescriptor(flags.get("CaravanCargo"), this.CaravanCargoDescriptors)));
        this.populateCaravanInventory(_caravan, _settlement);

        if (::Math.rand(1, 100) <= this.Mod.ModSettings.getSetting("CaravanReinforcementChance").getValue() || flags.get("CaravanWealth") >= this.CaravanWealthDescriptors.Plentiful)
        {
            this.reinforceCaravanTroops(_caravan, _settlement);
        }
    }

    function isPartyViable( _flags )
    {
        return _flags.get("IsCaravan");
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
        local timeModifier = ::Math.floor(currentTimeDays / this.Parameters.ReinforcementThresholdDays);
        local naiveIterations = ::Math.rand(1, wealth * 2) + timeModifier;
        local iterations = naiveIterations > this.Parameters.ReinforcementMaximumTroopOffset ? this.Parameters.ReinforcementMaximumTroopOffset : naiveIterations;
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

        if (currentTimeDays < this.Parameters.ReinforcementThresholdDays)
        {
            return;
        }

        local eliteTroops = this.createEliteCaravanTroops(factionType);
        ::Const.World.Common.addTroop(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, true);
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
                this.log("Invalid caravan cargo value, unable to retrieve icon.", true);
        }
    }

    function retrieveNamedCaravanCargo( _lootTable )
    {
        local namedCargo = this.createNamedLoot();
        local namedItem = ::new("scripts/items/" + namedCargo[::Math.rand(0, namedCargo.len() - 1)]);
        namedItem.onAddedToStash(null);
        this.log(format("Added %s to the loot table.", namedItem.getName()));
        _lootTable.push(namedItem);
    }
};