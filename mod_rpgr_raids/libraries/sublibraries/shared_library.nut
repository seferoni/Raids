local Raids = ::RPGR_Raids;
Raids.Shared <-
{
    Parameters =
    {
        GlobalProximityTiles = 9
    },

    function addToInventory( _party, _goodsPool )
    {
        local iterations = Raids.Caravans.isPartyInitialised(_party) ? ::Math.rand(1, Raids.Standard.getFlag("CaravanWealth", _party) - 1) : ::Math.rand(1, 2);

        for( local i = 0; i < iterations; i++ )
        {
            local good = _goodsPool[::Math.rand(0, _goodsPool.len() - 1)];
            Raids.Standard.log(format("Added item with filepath %s to the inventory of %s.", good, _party.getName()));
            _party.addToInventory(good);
        }
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
        ],
        southernGoods =
        [
            "supplies/dates_item",
            "supplies/rice_item",
            "trade/silk_item",
            "trade/spices_item",
            "trade/incense_item"
        ],
        southernFactions =
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
        local goods = scriptFiles.map(@(_stringPath) _stringPath.slice(culledString.len()));
        return goods;
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

        if (::Math.rand(1, 100) > ::RPGR_Raids.Lairs.Parameters.FactionSpecificNamedLootChance)
        {
            Raids.Standard.log(format("Returning naive named loot tables for %s.", _lair.getName()));
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
            Raids.Standard.log(format("%s has no non-empty named loot tables, returning naive named loot tables.", _lair.getName()));
            return this.createNaiveNamedLoot(namedItemKeys);
        }

        return namedLoot;
    }

    function isPlayerInProximityTo( _targetTile, _maximumProximity = 9 )
    {
        return ::World.State.getPlayer().getTile().getDistanceTo(_targetTile) <= _maximumProximity;
    }
};