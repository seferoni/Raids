this.edict_of_abundance <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_abundance";
		this.m.Name = "Edict of Abundance";
		this.setDescription("It speculates on an upsurge of demand for locally sourced trade goods.");
		this.m.Value = 50;
		this.m.DiscoveryDays = 2;
		this.m.ScalingModality = this.ScalingModalities.Agitation;
		this.m.EffectText = "Will induce nearby lairs to stock more high-value goods in their inventories.";
	}
});