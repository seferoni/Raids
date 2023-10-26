local Raids = ::RPGR_Raids;
this.edict_of_perspicuity <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_perspicuity";
		this.m.Name = "Edict of Perspicuity";
		this.setDescription("It purports to map common stash spots and trafficking routes frequented by the enemies of the realm.");
		this.m.Value = 200;
		this.m.EffectText <- "Will induce nearby lairs to reveal the contents of their inventory. This edict's effects are permanent.";
	}
});