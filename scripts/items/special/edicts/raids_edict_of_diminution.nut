this.raids_edict_of_diminution <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.assignPropertiesByName("Diminution");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.m.Value = 100;
	}

	function assignEdictProperties()
	{
		this.raids_edict_item.assignEdictProperties();
		this.m.DiscoveryDays = 2;
		this.m.ScalingModality = this.ScalingModalities.Agitation;
	}
});