this.raids_edict_of_prospecting_item <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.raids_edict_item.create();
		this.assignPropertiesByName("Prospecting");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.setNativeValue(150);
	}

	function assignEdictProperties()
	{
		this.raids_edict_item.assignEdictProperties();
		this.m.DiscoveryDays = 2;
		this.m.ScalingModality = this.getScalingModalities().Resources;
	}
});