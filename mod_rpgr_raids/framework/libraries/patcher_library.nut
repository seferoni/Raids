::Raids.Patcher <-
{
	function cacheHookedMethod( _object, _methodName )
	{
		local naiveMethod = null;

		if (_methodName in _object)
		{
			naiveMethod = _object[_methodName];
		}

		return naiveMethod;
	}

	function formatPath( _path )
	{
		return _path.slice("scripts/".len());
	}

	function getParentName( _object )
	{
		if (!("SuperName" in _object))
		{
			return null;
		}

		return _object.SuperName;
	}

	function getMethodFromParent( _object, _parentName, _methodName )
	{
		local dummy = function();

		if (_parentName == null)
		{
			return dummy;
		}

		return _object[_parentName][_methodName];
	}

	function hook( _path, _function )
	{
		if (::Raids.Manager.isModernHooksInstalled())
		{
			::Raids.Integrations.ModernHooks.hook(_path, _function);
			return;
		}

		::Raids.Integrations.ModdingScriptHooks.hook(this.formatPath(_path), _function);
	}

	function hookBase( _path, _function )
	{
		if (::Raids.Manager.isModernHooksInstalled())
		{
			::Raids.Integrations.ModernHooks.hookBase(_path, _function);
			return;
		}

		::Raids.Integrations.ModdingScriptHooks.hookBase(this.formatPath(_path), _function);
	}

	function hookTree( _path, _function )
	{
		if (::Raids.Manager.isModernHooksInstalled())
		{
			::Raids.Integrations.ModernHooks.hookTree(_path, _function);
			return;
		}

		::Raids.Integrations.ModdingScriptHooks.hookTree(this.formatPath(_path), _function);
	}

	# Calls new method and passes result onto original method; if null, calls original method with original arguments.
	# It is the responsibility of the overriding function to return appropriate arguments.
	function overrideArguments( _object, _function, _originalMethod, _argumentsArray )
	{
		local returnValue = _function.acall(_argumentsArray),
		newArguments = returnValue == null ? _argumentsArray : this.prependContextObject(_object, returnValue);
		return _originalMethod.acall(newArguments);
	}

	# Calls and returns new method; if return value is null, calls and returns original method.
	function overrideMethod( _object, _function, _originalMethod, _argumentsArray )
	{
		local returnValue = _function.acall(_argumentsArray);
		return returnValue == null ? _originalMethod.acall(_argumentsArray) : (returnValue == ::Raids.Internal.TERMINATE ? null : returnValue);
	}

	# Calls original method and passes result onto new method, returns new result.
	# It is the responsibility of the overriding function to ensure it takes on the appropriate arguments and returns appropriate values.
	function overrideReturn( _object, _function, _originalMethod, _argumentsArray )
	{
		local originalValue = _originalMethod.acall(_argumentsArray);

		if (originalValue != null)
		{
			_argumentsArray.insert(1, originalValue);
		}

		local returnValue = _function.acall(_argumentsArray);
		return returnValue == null ? originalValue : (returnValue == ::Raids.Internal.TERMINATE ? null : returnValue);
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
		local originalInfo = _originalFunction.getinfos();
		local originalParameters = originalInfo.parameters;

		# Return a trivial evaluation if the evaluated function accepts variable arguments.
		if (originalParameters[originalParameters.len() - 1] == "...")
		{
			return true;
		}

		# This offset here accounts for the inclusion of the context object.
		local newLength = _newParameters.len() + 1;

		if (newLength <= originalParameters.len() && newLength >= originalParameters.len() - originalInfo.defparams.len())
		{
			return true;
		}

		return false;
	}

	function wrap( _object, _methodName, _function, _procedure = "overrideReturn" )
	{
		# Assign reference to the name of the parent of the target object.
		local parentName = this.getParentName(_object);

		# Attempt to store a reference to the original method (which may be inherited), to preserve functionality when wrapped (if applicable).
		local cachedMethod = this.cacheHookedMethod(_object, _methodName);

		_object.rawset(_methodName, function( ... )
		{
			# Assign a reference to the original method.
			local originalMethod = cachedMethod == null ? ::Raids.Patcher.getMethodFromParent(this, parentName, _methodName) : cachedMethod;

			if (!::Raids.Patcher.validateParameters(originalMethod, vargv))
			{
				::Raids.Standard.log(format("An invalid number of parameters were passed to %s, aborting wrap procedure.", _methodName), true);
				return;
			}

			local argumentsArray = ::Raids.Patcher.prependContextObject(this, vargv);
			return ::Raids.Patcher[_procedure](this, _function, originalMethod, argumentsArray);
		});
	}
};