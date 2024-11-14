::Raids.Database <-
{
	function createTables()
	{
		this.Parameters <- {};
		this.Parameters.Caravans <- {};
		this.Parameters.Edicts <- {};
		this.Parameters.Lairs <- {};
	}

	function getIcon( _iconKey )
	{
		if (!_iconKey in this.Icons)
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
	}

	function initialise()
	{
		this.createTables();
		this.loadFiles();
	}
};