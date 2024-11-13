::Raids <-
{
	ID = "mod_rpgr_raids",
	Name = "RPG Rebalance - Raids",
	Version = "5.0.0",
	Internal =
	{
		ManagerPath = "mod_rpgr_raids/framework/internal/manager.nut",
		TERMINATE = "__end"
	}

	function loadManager()
	{
		::include(this.Internal.ManagerPath);
	}

	function initialise()
	{
		this.loadManager();
		this.Manager.awake();
		this.Manager.queue();
	}
};

::Raids.initialise();