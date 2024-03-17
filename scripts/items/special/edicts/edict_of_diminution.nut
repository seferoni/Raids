local Raids = ::RPGR_Raids;
this.edict_of_diminution <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_diminution";
		this.m.Name = "Edict of Diminution";
		this.setDescription("It maps far-flung locations of supposedly long-abandoned spoils of war littered about the realm.");
		this.m.Value = 100;
		this.m.ScalingModality = this.ScalingModalities.Resources;
		this.m.EffectText = format("Will induce nearby lairs to lose resources. Has %s effect on lairs with low resources.", Raids.Standard.colourWrap("minimal", Raids.Standard.Colour.Red));
	}
});