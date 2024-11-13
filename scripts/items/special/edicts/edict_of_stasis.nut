this.edict_of_stasis <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_stasis";
		this.m.Name = "Edict of Stasis";
		this.setDescription("It signals the extension of a period of unrest and uncertainty.");
		this.m.Value = 25;
		this.m.ScalingModality = this.ScalingModalities.Agitation;
		this.m.EffectText = "Will increase the time required for nearby lairs to lose Agitation.";
	}
});