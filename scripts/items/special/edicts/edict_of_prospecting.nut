this.edict_of_prospecting <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_prospecting";
		this.m.Name = "Edict of Prospecting";
		this.setDescription("It maps local points of interest rumoured to house long-sought artefacts of innumerable worth.");
		this.m.Value = 150;
		this.m.DiscoveryDays = 2;
		this.m.ScalingModality = this.ScalingModalities.Resources;
		this.m.EffectText = "Will increase the chance that nearby lairs discover new Famed items.";
	}
});