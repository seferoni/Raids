this.raids_edict_of_abundance <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.assignPropertiesByName("Abundance");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.m.Value = 50;
	}

	function assignEdictProperties()
	{
		this.raids_edict_item.assignEdictProperties();
		this.m.DiscoveryDays = 2;
		this.m.ScalingModality = this.getScalingModalities().Agitation;
	}
});