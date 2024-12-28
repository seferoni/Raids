::Raids.Database <-
{
	function createTables()
	{
		this.Settings <- {};
		this.Generic <- {};
		this.Caravans <- {};
		this.Defenders <- {};
		this.Edicts <- {};
		this.Lairs <- {};
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

	function getTopLevelField( _tableName, _fieldName )
	{
		if (!(_fieldName in this[_tableName]))
		{
			return null;
		}

		return this[_tableName][_fieldName];
	}

	function getIcon( _iconKey )
	{
		if (!_iconKey in this.Generic.Icons)
		{
			return null;
		}

		return format("ui/icons/%s", this.Icons[_iconKey]);
	}

	function getSettingParameters()
	{
		local agglomeratedParameters = {};

		foreach( parameterType, parameterTable in this.Settings )
		{
			::Raids.Standard.extendTable(parameterDictionary, agglomeratedParameters);
		}

		return agglomeratedParameters;
	}

	function getSettingCategories()
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
		this.loadFolder("settings");
	}

	function initialise()
	{
		this.createTables();
		this.loadFiles();
	}
};