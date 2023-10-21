local Raids = ::RPGR_Raids;
this.edict_of_agitation <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_agitation";
		this.m.Name = "Edict of Agitation";
		this.setDescription("It specifies the date, time, and mustered strength of a scheduled raid.");
		this.m.Value = 20;
		this.m.EffectText <- "Will agitate the closest nearby lair. This edict's effects are temporary.";
	}
});