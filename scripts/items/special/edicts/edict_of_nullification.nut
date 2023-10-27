local Raids = ::RPGR_Raids;
this.edict_of_nullification <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_nullification";
		this.m.Name = "Edict of Nullification";
		this.setDescription("It signals the end of a somewhat unusual state of affairs.");
		this.m.Value = 50;
		this.m.EffectText <- "Will clear the effects of all other edicts on nearby lairs. This edict's effects are temporary.";
	}
});