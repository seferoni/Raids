::Raids.Strings <-
{
	function createTables()
	{
		this.Edicts <- {};
	}

	function compileFragments( _fragmentsArray, _colour )
	{
		local compiledString = "";

		if (_fragmentsArray.len() % 2 != 0)
		{
			_fragmentsArray.push("");
		}

		::logInfo("have an array of length " + _fragmentsArray.len())
		::logInfo("final entry is '" + _fragmentsArray[_fragmentsArray.len() - 1] + "'");

		for( local i = 0; i < _fragmentsArray.len(); i++ )
		{
			local fragment = i % 2 == 0 ? _fragmentsArray[i] : ::Raids.Standard.colourWrap(_fragmentsArray[i], ::Raids.Standard.Colour[_colour]);
			::logInfo("appending '" + fragment + "' to list")
			compiledString = ::Raids.Standard.appendToStringList(fragment, compiledString, "");
		}

		return compiledString;
	}

	function getField( _tableName, _fieldName )
	{
		local field = this.getTopLevelField(_tableName, _fieldName);

		if (field == null)
		{
			field = this.getSubLevelField(_tableName, _fieldName);
		}

		return field;
	}

	function getFragmentsAsArray( _fragmentBase, _tableKey, _fragmentCount )
	{
		local fragments = [];

		for( local i = 0; i < _fragmentCount; i++ )
		{
			local stringKey = format("%s%s", _fragmentBase, this.mapIntegerToAlphabet(i));
			fragments.push(this.getField(_tableKey, stringKey));
		}

		return fragments;
	}

	function getFragmentsAsCompiledString( _fragmentBase, _tableKey, _fragmentCount  = 4, _colour = "Red")
	{	# NB: Indexed keys must have unique names within the context of the string database.
		local fragmentsArray = this.getFragmentsAsArray(_fragmentBase, _tableKey, _fragmentCount);
		return this.compileFragments(fragmentsArray, _colour);
	}

	function getSubLevelField( _tableName, _fieldName )
	{
		foreach( subtableName, nestedTable in this[_tableName] )
		{
			::logInfo("looking for " + _fieldName + " in " + subtableName);
			if (!(_fieldName in nestedTable))
			{
				continue;
			}

			return this[_tableName][subtableName][_fieldName];
		}
	}

	function getTopLevelField( _tableName, _fieldName )
	{
		if (!(_fieldName in this[_tableName]))
		{
			return null;
		}

		return this[_tableName][_fieldName];
	}

	function mapIntegerToAlphabet( _integer )
	{
		local ASCIIValue = 65 + _integer;
		return ASCIIValue.tochar();
	}

	function loadFiles()
	{
		this.loadFolder("main");
		this.loadFolder("edicts");
	}

	function loadFolder( _path )
	{
		::Raids.Manager.includeFiles(format("mod_rpgr_raids/framework/strings/%s", _path));
	}

	function initialise()
	{
		this.createTables();
		this.loadFiles();
	}
};