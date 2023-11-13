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

        return format("[color=%s]%s[/color]", ::Const.UI.Color[_colour], string)
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

    function getFlag( _string, _object )
    {
        local flagValue = _object.getFlags().get(format("mod_rpgr_raids.%s", _string));

        if (flagValue == false)
        {
            flagValue = _object.getFlags().get(format("%s", _string));
        }

        return flagValue;
    }

    function getFlagAsInt( _string, _object )
    {
        local flagValue = _object.getFlags().getAsInt(format("mod_rpgr_raids.%s", _string));

        if (flagValue == 0)
        {
            flagValue = _object.getFlags().getAsInt(format("%s", _string));
        }

        return flagValue;
    }

    function getPercentageSetting( _settingID )
    {
        return (this.getSetting(_settingID) / 100.0)
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

    function includeFiles( _path )
    {
        foreach( file in ::IO.enumerateFiles(_path) )
        {
            ::include(file);
        }
    }

    function incrementFlag( _string, _value, _object, _isNative = false )
    {
        local flag = _isNative ? format("%s", _string) : format("mod_rpgr_raids.%s", _string);
        _object.getFlags().increment(flag, _value);
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

    function overrideArguments( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls new method and passes result onto original method; if null, calls original method with original arguments.
        # It is the responsibility of the overriding function to return appropriate arguments.
        local returnValue = _function.acall(_argumentsArray),
        newArguments = returnValue == null ? _argumentsArray : this.prependContextObject(_object, returnValue);
        return _originalMethod.acall(newArguments);
    }

    function overrideMethod( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls and returns new method; if return value is null, calls and returns original method.
        local returnValue = _function.acall(_argumentsArray);
        return returnValue == null ? _originalMethod.acall(_argumentsArray) : (returnValue == Raids.Internal.TERMINATE ? null : returnValue);
    }

    function overrideReturn( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls original method and passes result onto new method, returns new result.
        # It is the responsibility of the overriding function to ensure it takes on the appropriate arguments and returns appropriate values.
        local originalValue = _originalMethod.acall(_argumentsArray);
        if (originalValue != null) _argumentsArray.insert(1, originalValue);
        local returnValue = _function.acall(_argumentsArray);
        return returnValue == null ? originalValue : (returnValue == Raids.Internal.TERMINATE ? null : returnValue);
    }
    
    function parseSemVer( _version )
    {
        local versionArray = split(_version, ".");
        if (versionArray.len() > 3) versionArray.resize(3);
        return format("%s.%s%s", versionArray[0], versionArray[1], versionArray[2]).tofloat();
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

    function setCase( _string, _case )
    {
        local character = _string[0].tochar()[_case]();
        return format("%s%s", character, _string.slice(1));
    }

    function setFlag( _string, _value, _object, _isNative = false )
    {
        local flag = _isNative ? format("%s", _string) : format("mod_rpgr_raids.%s", _string);
        _object.getFlags().set(flag, _value);
    }

    function validateParameters( _originalFunction, _newParameters )
    {
        local originalInfo = _originalFunction.getinfos(), originalParameters = originalInfo.parameters;

        if (originalParameters[originalParameters.len() - 1] == "...")
        {
            return true;
        }

        local newLength = _newParameters.len() + 1;

        if (newLength <= originalParameters.len() && newLength >= originalParameters.len() - originalInfo.defparams.len())
        {
            return true;
        }

        return false;
    }

    function wrap( _object, _functionName, _function, _procedure = "overrideReturn" )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName),
        Standard = ::RPGR_Raids.Standard,
        parentName = _object.SuperName;

        _object.rawset(_functionName, function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod;

            if (!Standard.validateParameters(originalMethod, vargv))
            {
                Standard.log(format("An invalid number of parameters were passed to %s, aborting wrap procedure.", _functionName), true);
                return;
            }

            local argumentsArray = Standard.prependContextObject(this, vargv);
            return Standard[_procedure](this, _function, originalMethod, argumentsArray);
        });
    }
};
