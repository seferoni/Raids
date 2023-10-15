local Raids = ::RPGR_Raids;
this.edict_of_provocation <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_provocation";
		this.m.Name = "Edict of Provocation";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. This document appraises the martial capabilities of the enemies of the realm, and subsequently finds them lacking.";
		this.m.Value = 50;
        this.m.EffectText <- "Will issue a challenge to the closest lairs, forcing them to send out stronger roaming parties. This edict's effects are permanent.";
	}
});