::Raids.Manager <-
{
	function awake()
	{
		this.createTables();
		this.updateIntegrationRegistry();
		this.register();
	}

	function createMSUInterface()
	{
		if (!this.isMSUInstalled())
		{
			return;
		}

		::Raids.Interfaces.MSU <- ::MSU.Class.Mod(::Raids.ID, ::Raids.Version, ::Raids.Name);
	}

	function createTables()
	{
		::Raids.Interfaces <- {};
	}

	function formatVersion()
	{
		if (this.isMSUInstalled())
		{
			return;
		}

		if (this.isModernHooksInstalled())
		{
			return;
		}

		::Raids.Version = this.parseSemVer(::Raids.Version);
	}

	function isMSUInstalled()
	{
		return ::Raids.Internal.MSUFound;
	}

	function isModernHooksInstalled()
	{
		return ::Raids.Internal.ModernHooksFound;
	}

	function initialise()
	{
		this.createMSUInterface();
		this.loadLibraries();
		this.loadHandlers();
		this.initialiseHandlers();
		this.loadFiles();
	}

	function initialiseHandlers()
	{
		::Raids.Database.initialise();
		::Raids.Strings.initialise();
		::Raids.Integrations.initialise();
	}

	function includeFiles( _path )
	{
		local filePaths = ::IO.enumerateFiles(_path);

		foreach( file in filePaths )
		{
			::include(file);
		}
	}

	function loadHandlers()
	{
		::include("mod_rpgr_raids/framework/database/database_handler.nut");
		::include("mod_rpgr_raids/framework/strings/string_handler.nut");
		::include("mod_rpgr_raids/framework/integrations/mod_integration.nut");
	}

	function loadLibraries()
	{
		::include("mod_rpgr_raids/framework/libraries/standard_library.nut");
		::include("mod_rpgr_raids/framework/libraries/patcher_library.nut");
	}

	function loadFiles()
	{
		this.includeFiles("mod_rpgr_raids/framework/classes/main");
		this.includeFiles("mod_rpgr_raids/framework/classes/utils");
		this.includeFiles("mod_rpgr_raids/hooks");
	}

	function parseSemVer( _versionString )
	{
		local stringArray = split(_versionString, ".");

		if (stringArray.len() > 3)
		{
			stringArray.resize(3);
		}

		return format("%s.%s%s", stringArray[0], stringArray[1], stringArray[2]).tofloat();
	}

	function queue()
	{
		local queued = @() ::Raids.Manager.initialise();

		if (this.isModernHooksInstalled())
		{
			::Raids.Interfaces.ModernHooks.queue(">mod_msu", queued);
			return;
		}

		::mods_queue(::Raids.ID, ">mod_msu", queued);
	}

	function register()
	{
		this.formatVersion();
		this.registerMod();
	}

	function registerJS( _path )
	{
		if (this.isModernHooksInstalled())
		{
			::Hooks.registerJS(format("ui/mods/mod_rpgr_raids/%s", _path));
			return;
		}

		::mods_registerJS(format("mod_rpgr_raids/%s", _path));
	}

	function registerMod()
	{
		if (this.isModernHooksInstalled())
		{
			::Raids.Interfaces.ModernHooks <- ::Hooks.register(::Raids.ID, ::Raids.Version, ::Raids.Name);
			return;
		}

		::mods_registerMod(::Raids.ID, ::Raids.Version, ::Raids.Name);
	}

	function updateIntegrationRegistry()
	{
		this.updateMSUState();
		this.updateModernHooksState();
	}

	function updateMSUState()
	{
		::Raids.Internal.MSUFound <- "MSU" in ::getroottable();
	}

	function updateModernHooksState()
	{
		::Raids.Internal.ModernHooksFound <- "Hooks" in ::getroottable();
	}
};