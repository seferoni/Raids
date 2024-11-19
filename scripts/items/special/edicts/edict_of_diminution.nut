this.edict_of_diminution <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_diminution";
		this.m.Name = "Edict of Diminution";
		this.setDescription("It maps far-flung locations of supposedly long-abandoned spoils of war littered about the realm.");
		this.m.Value = 100;
		this.m.DiscoveryDays = 2;
		this.m.ScalingModality = this.ScalingModalities.Agitation;
		this.m.EffectText = "Will weaken nearby lairs.";
	}
});