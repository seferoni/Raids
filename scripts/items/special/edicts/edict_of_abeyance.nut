local Raids = ::RPGR_Raids;
this.edict_of_abeyance <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_abeyance";
		this.m.Name = "Edict of Abeyance";
		this.setDescription("It speculates on an upsurge of demand for fabled heirlooms of the realm.");
		this.m.Value = 25;
		this.m.EffectText <- "Will reduce the chance of nearby lairs clearing famed items within their inventory over time. This edict's effects are permanent.";
	}
});