this.raids_edict_of_opportunism_item <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.raids_edict_item.create();
		this.assignPropertiesByName("Opportunism");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.setNativeValue(50);
	}

	function assignEdictProperties()
	{
		this.raids_edict_item.assignEdictProperties();
		this.m.DiscoveryDays = 3;
	}
});