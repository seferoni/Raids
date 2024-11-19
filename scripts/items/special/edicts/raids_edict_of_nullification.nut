this.raids_edict_of_nullification <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.raids_edict_item.create();
		this.assignPropertiesByName("Nullification");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.m.Value = 50;
	}

	function assignEdictProperties()
	{
		this.raids_edict_item.assignEdictProperties();
		this.m.DiscoveryDays = 3;
	}
});