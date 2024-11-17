::Raids.Database <-
{
	function createTables()
	{
		this.Parameters <- {};
		this.Parameters.Caravans <- {};
		this.Parameters.Defenders <- {};
		this.Parameters.Edicts <- {};
		this.Parameters.Lairs <- {};
	}

	function getTopLevelField( _tableName, _fieldName )
	{
		if (!(_fieldName in this[_tableName]))
		{
			return null;
		}

		return this[_tableName][_fieldName];
	}

	function getSubLevelField( _tableName, _fieldName )
	{
		foreach( subtableName, nestedTable in this[_tableName] )
		{
			if (!(_fieldName in nestedTable))
			{
				continue;
			}

			return this[_tableName][subtableName][_fieldName];
		}
	}

	function getIcon( _iconKey )
	{
		if (!_iconKey in this.Generic.Icons)
		{
			return null;
		}

		return format("ui/icons/%s", this.Icons[_iconKey]);
	}

	function getParameters()
	{
		local agglomeratedParameters = {};

		foreach( parameterType, parameterTable in this.Parameters )
		{
			::Raids.Standard.extendTable(parameterDictionary, agglomeratedParameters);
		}

		return agglomeratedParameters;
	}

	function getParameterCategories()
	{
		return ::Raids.Standard.getKeys(this.Settings);
	}

	function loadFolder( _path )
	{
		::Raids.Manager.includeFiles(format("mod_rpgr_raids/framework/database/%s", _path));
	}

	function loadFiles()
	{
		this.loadFolder("dictionaries");
		this.loadFolder("parameters");
	}

	function initialise()
	{
		this.createTables();
		this.loadFiles();
	}
};