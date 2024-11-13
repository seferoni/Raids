::Raids.Integrations <-
{
	function initialise()
	{
		this.loadAPI();
		this.initialiseAPI();
	}

	function initialiseAPI()
	{
		this.initialiseMSUAPI();
	}

	function initialiseMSUAPI()
	{
		if (!::Raids.Manager.isMSUInstalled())
		{
			return;
		}

		this.MSU.initialise();
	}

	function loadFile( _fileName )
	{
		::include(format("mod_rpgr_raids/framework/integrations/%s", _fileName));
	}

	function loadAPI()
	{
		this.loadFile("msu/msu_settings_api.nut");
		this.loadFile("modern_hooks/modern_hooks_api.nut");
		this.loadFile("modding_script_hooks/modding_script_hooks_api.nut");
	}
};