this.raids_edict_of_abundance_item <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.raids_edict_item.create();
		this.assignPropertiesByName("Abundance");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.setNativeValue(50);
	}

	function assignEdictProperties()
	{
		this.raids_edict_item.assignEdictProperties();
		this.m.DiscoveryDays = 2;
		this.m.ScalingModality = this.getScalingModalities().Agitation;
	}
});