::Raids.Standard <-
{
	Case =
	{
		Upper = "toupper",
		Lower = "tolower"
	},
	Colour =
	{
		Green = "#2a5424",
		Red = "#691a1a"
	},
	Procedures =
	{
		Reset = 0,
		Increase = 1,
		Decrease = 2
	},
	Tooltip =
	{
		id = 7,
		type = "text",
		icon = "",
		text = ""
	}

	function appendToStringList( _string, _list )
	{
		local newString = _list == "" ? format("%s", _string) : format("%s, %s", _list, _string);
		return newString;
	}

	function cacheHookedMethod( _object, _methodName )
	{
		local naiveMethod = null;

		if (_methodName in _object)
		{
			naiveMethod = _object[_methodName];
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

		return format("[color=%s]%s[/color]", _colour, string)
	}

	function constructEntry( _icon, _text, _parentArray = null )
	{
		local entry = clone this.Tooltip;

		if (_icon != null)
		{
			entry.icon <- ::Raids.Database.getIcon(_icon);
		}

		entry.text <- _text;

		if (_parentArray == null)
		{
			return entry;
		}

		_parentArray.push(entry);
	}

	function extendTable( _table, _targetTable )
	{
		foreach( key, value in _table )
		{
			_targetTable[key] <- value;
		}
	}

	function getArrayAsList( _array )
	{
		local list = "";

		foreach( entry in _array )
		{
			list = this.appendToStringList(entry, list);
		}

		return list;
	}

	function getFlag( _string, _object )
	{
		local flagValue = _object.getFlags().get(format("%s.%s", ::Raids.ID, _string));

		if (flagValue == false)
		{
			flagValue = _object.getFlags().get(format("%s", _string));
		}

		return flagValue;
	}

	function getFlagAsInt( _string, _object )
	{
		local flagValue = _object.getFlags().getAsInt(format("%s.%s", ::Raids.ID, _string));

		if (flagValue == 0)
		{
			flagValue = _object.getFlags().getAsInt(format("%s", _string));
		}

		return flagValue;
	}

	function getKey( _valueToMatch, _table )
	{
		foreach( key, value in _table )
		{
			if (value == _valueToMatch)
			{
				return key;
			}
		}
	}

	function getKeys( _table )
	{
		local returnArray = [];

		foreach( key, value in _table )
		{
			returnArray.push(key);
		}

		return returnArray;
	}

	function getPlayerByID( _playerID )
	{
		local roster = ::World.getPlayerRoster().getAll();

		foreach( player in roster )
		{
			local candidateID = player.getID();

			if (_playerID == candidateID)
			{
				return player;
			}
		}

		return null;
	}

	function getParameter( _parameterID )
	{
		if (::Raids.Manager.isMSUInstalled())
		{
			return ::Raids.Interfaces.MSU.ModSettings.getParameter(_parameterID).getValue();
		}

		local parameters = ::Raids.Database.getParameters();

		foreach( parameterKey, parameterTable in parameters )
		{
			if (_parameterID == parameterKey)
			{
				return parameterTable.Default;
			}
		}

		this.log(format("Invalid parameter key %s passed to getParameter.", _parameterKey), true);
	}

	function getPercentageParameter( _parameterID )
	{
		return (this.getParameter(_parameterID) / 100.0);
	}

	function getListAsArray( _string )
	{
		local entries = split(_string, ", ");
		return entries;
	}

	function includeFiles( _path )
	{
		local filePaths = ::IO.enumerateFiles(_path);

		foreach( file in filePaths )
		{
			::include(file);
		}
	}

	function incrementFlag( _string, _value, _object, _isNative = false )
	{
		local flag = _isNative ? format("%s", _string) : format("%s.%s", ::Raids.ID, _string);
		_object.getFlags().increment(flag, _value);
	}

	function isWeakRef( _object )
	{
		if (typeof _object != "instance")
		{
			return false;
		}

		if (!(_object instanceof ::WeakTableRef))
		{
			return false;
		}

		return true;
	}

	function log( _string, _isError = false )
	{
		if (_isError)
		{
			::logError(format("[Survival] %s", _string));
			return;
		}

		::logInfo(format("[Survival] %s", _string));
	}

	function push( _object, _targetArray )
	{
		if (_object == null)
		{
			return;
		}

		local entry = _object;

		if (typeof entry != "array")
		{
			entry = [_object];
		}

		_targetArray.extend(entry);
	}

	function replaceSubstring( _substring, _newSubstring, _targetString )
	{
		local startIndex = _targetString.find(_substring);

		if (startIndex == null)
		{
			return _targetString;
		}

		return format("%s%s%s", _targetString.slice(0, startIndex), _newSubstring, _targetString.slice(startIndex + _substring.len()));
	}

	function removeFromArray( _target, _array )
	{
		local targetArray = typeof _target == "array" ? _target : [_target];

		foreach( entry in targetArray )
		{
			local index = _array.find(entry);

			if (index != null)
			{
				_array.remove(index);
			}
		}
	}

	function setCase( _string, _case )
	{
		local character = _string[0].tochar()[_case]();
		return format("%s%s", character, _string.slice(1));
	}

	function setFlag( _string, _value, _object, _isNative = false )
	{
		local flag = _isNative ? format("%s", _string) : format("%s.%s", ::Raids.ID, _string);
		_object.getFlags().set(flag, _value);
	}
};
