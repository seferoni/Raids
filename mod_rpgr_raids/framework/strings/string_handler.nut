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

		for( local i = 0; i < _fragmentsArray.len(); i++ )
		{
			local fragment = i % 2 == 0 ? _fragmentsArray[i] : ::Raids.Standard.colourWrap(_fragmentsArray[i], ::Raids.Standard.Colour[_colour]);
			compiledString = ::Raids.Standard.appendToStringList(fragment, compiledString, "");
		}

		return compiledString;
	}

	function getFragmentsAsArray( _fragmentBase, _tableKey, _subTableKey )
	{
		local fragments = [];
		local database = _subTableKey == null ? this[_tableKey] : this[_tableKey][_subTableKey];

		foreach( key, string in database )
		{
			if (key.find(_fragmentBase) != null)
			{
				fragments.push(string);
			}	// TODO: this may need alphabetical sorting?
		}

		return fragments;
	}

	function getFragmentsAsCompiledString( _fragmentBase, _tableKey, _subTableKey = null, _colour = "Red")
	{	# NB: Indexed keys must have unique names within the context of the string database.
		local fragmentsArray = this.getFragmentsAsArray(_fragmentBase, _tableKey, _subTableKey);
		return this.compileFragments(fragmentsArray, _colour);
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