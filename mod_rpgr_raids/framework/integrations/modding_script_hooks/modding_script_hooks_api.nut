::Raids.Integrations.ModdingScriptHooks <-
{
	function hook( _path, _function )
	{
		::mods_hookExactClass(_path, _function);
	}

	function hookBase( _path, _function )
	{
		::mods_hookNewObject(_path, _function);
	}

	function hookTree( _path, _function )
	{
		::mods_hookBaseClass(_path, _function);
	}
};