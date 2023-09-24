::RPGR_Raids.Standard <-
{
    Parameters =
    {
        GlobalProximityTiles = 9
    },

    /*function acall( _function, _argumentsArray )
    {
        switch(_argumentsArray.len())
        {
            case(0):
            {
                return _function();
            }

            case(1):
            {
                return _function(_argumentsArray[0]);
            }

            case(2):
            {
                return _function(_argumentsArray[0], _argumentsArray[1]);
            }

            case(3):
            {
                return _function(_argumentsArray[0], _argumentsArray[1], _argumentsArray[2]);
            }

            case(4):
            {
                return _function(_argumentsArray[0], _argumentsArray[1], _argumentsArray[2], _argumentsArray[3]);
            }
        }
    }*/

    function addToInventory( _party, _goodsPool, _isCaravan = false ) // TODO: this doesn't need the isCaravan argument, rewrite
    {
        local iterations = _party.getFlags().get("CaravanWealth") != false ? ::Math.rand(1, _party.getFlags().get("CaravanWealth") - 1) : ::Math.rand(1, 2);

        for( local i = 0; i < iterations; i++ )
        {
            local good = _goodsPool[::Math.rand(0, _goodsPool.len() - 1)];
            this.logWrapper(format("Added item with filepath %s to the inventory of %s.", good, _party.getName()));
            _party.addToInventory(good);
        }
    }

    function cacheHookedMethod( _object, _functionName )
    {
        local naiveMethod = null;
        local parentName = _object.SuperName;

        if (_functionName in _object)
        {
            naiveMethod = _object[_functionName];
        }

        return naiveMethod;
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
            this.logWrapper(format("%s has no non-empty named loot tables, returning naive named loot tables.", _lair.getName()));
            return this.createNaiveNamedLoot(namedItemKeys);
        }

        return namedLoot;
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

    function generateOrderedArray( _firstEntry, _secondEntry, _procedure )
    {
        local orderedArray = [_firstEntry, _secondEntry];

        if (_procedure[0] == "reverse")
        {
            orderedArray.reverse();
        }

        return orderedArray;
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

    function getSetting( _settingID )
    {
        if (::RPGR_Raids.MSUFound)
        {
            return ::RPGR_Raids.Mod.ModSettings.getSetting(_settingID).getValue();
        }

        if (!(_settingID in ::RPGR_Raids.Defaults))
        {
            this.logWrapper(format("Invalid settingID %s passed to getSetting, returning null.", _settingID), true);
            return null;
        }

        return ::RPGR_Raids.Defaults[_settingID];
    }

    function includeFiles( _path )
    {
        foreach( file in ::IO.enumerateFiles(_path) )
        {
            ::include(file);
        }
    }

    function isPlayerInProximityTo( _targetTile )
    {
        return ::World.State.getPlayer().getTile().getDistanceTo(_targetTile) <= this.Parameters.GlobalProximityTiles;
    }

    function logWrapper( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError(format("[Raids] %s", _string));
            return;
        }

        if (!this.getSetting("VerboseLogging"))
        {
            return;
        }

        ::logInfo(format("[Raids] %s", _string));
    }

    function orderedCall( _functions, _argumentsArray, _procedure, _returnOverride = null )
    {
        local returnValues = [];

        foreach( functionDef in _functions )
        {
            returnValues.push(functionDef.acall(_argumentsArray)); // TODO: see what context object we need to be in
        }

        return _procedure[1] == "returnFirst" ? returnValues[0] : _procedure[1] == "returnSecond" ? returnValue[1] : _returnOverride;
    }

    function wrap( _object, _functionName, _function, _procedure = [null, "returnFirst"], _returnOverride = null )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName);
        local parentName = _object.SuperName;

        _object[_functionName] = function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod;
            local orderedArray = this.generateOrderedArray(_function, originalMethod, _procedure);
            local arguments = clone vargv;
            arguments.insert(0, this);
            return ::RPGR_Raids.Standard.orderedCall(orderedArray, arguments, _procedure, _returnOverride);
        }
    }
};
