local Raids = ::RPGR_Raids;
Raids.Standard <-
{
    function cacheHookedMethod( _object, _functionName )
    {
        local naiveMethod = null;

        if (_functionName in _object)
        {
            naiveMethod = _object[_functionName];
        }

        return naiveMethod;
    }

    function colourWrap( _text, _colour )
    {
        local string = _text;

        if (typeof _text != "string")
        {
            string = _text.tostring();
        }

        return format("[color=%s] %s [/color]", ::Const.UI.Color[_colour], string)
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

    function getOriginalResult( _argumentsArray )
    {
        return _argumentsArray[0];
    }

    function getSetting( _settingID )
    {
        if (Raids.Internal.MSUFound)
        {
            return Raids.Mod.ModSettings.getSetting(_settingID).getValue();
        }

        if (!(_settingID in Raids.Defaults))
        {
            this.log(format("Invalid settingID %s passed to getSetting, returning null.", _settingID), true);
            return null;
        }

        return Raids.Defaults[_settingID];
    }

    function getPercentageSetting( _settingID )
    {
        return (this.getSetting(_settingID) / 100.0)
    }

    function includeFiles( _path )
    {
        foreach( file in ::IO.enumerateFiles(_path) )
        {
            ::include(file);
        }
    }

    function log( _string, _isError = false )
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

    function makeTooltip( _id, _type, _icon, _text )
    {
        local tableEntry =
        {
            id = _id,
            type = _type,
            icon = format("ui/icons/%s", _icon),
            text = _text
        }

        return tableEntry;
    }

    function overrideArguments( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls new method and passes result onto original method; if null, calls original method with original arguments.
        # It is the responsibility of the overriding function to return appropriate arguments.
        local returnValue = _function.acall(_argumentsArray);
        local newArguments = returnValue == null ? _argumentsArray : this.prependContextObject(_object, returnValue);
        return _originalMethod.acall(newArguments);
    }

    function overrideMethod( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls and returns new method; if return value is null, calls and returns original method.
        local returnValue = _function.acall(_argumentsArray);
        return returnValue == null ? _originalMethod.acall(_argumentsArray) : (returnValue == ::RPGR_Raids.Internal.TERMINATE ? null : returnValue);
    }

    function overrideReturn( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls original method and passes result onto new method, returns new result.
        # It is the responsibility of the overriding function to ensure it takes on the appropriate arguments and returns appropriate values.
        local originalValue = _originalMethod.acall(_argumentsArray);
        _argumentsArray.insert(1, originalValue);
        local returnValue = _function.acall(_argumentsArray);
        return returnValue == null ? originalValue : (returnValue == ::RPGR_Raids.Internal.TERMINATE ? null : returnValue);
    }

    function prependContextObject( _object, _arguments )
    {
        local array = [_object];

        if (typeof _arguments != "array")
        {
            array.push(_arguments);
            return array;
        }

        foreach( entry in _arguments )
        {
            array.push(entry);
        }

        return array;
    }

    function validateParameters( _originalFunction, _newParameters )
    {
        local oldParameters = _originalFunction.getinfos().parameters;

        if (oldParameters[oldParameters.len() - 1] == "...")
        {
            return true;
        }

        if (_newParameters.len() + 1 == oldParameters.len())
        {
            return true;
        }

        return false;
    }

    function wrap( _object, _functionName, _function, _procedure )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName),
        Raids = ::RPGR_Raids;
        parentName = _object.SuperName;

        _object.rawset(_functionName, function( ... ) // TODO: check if rawset is the right procedure here
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod;

            if (!Raids.Standard.validateParameters(originalMethod, vargv))
            {
                Raids.Standard.log(format("An invalid number of parameters were passed to %s, aborting wrap procedure.", _functionName), true);
                return;
            }

            local argumentsArray = Raids.Standard.prependContextObject(this, vargv);
            return Raids.Standard[_procedure](this, _function, originalMethod, argumentsArray);
        });
    }
};
