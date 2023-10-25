local Raids = ::RPGR_Raids;
this.edict_of_abundance <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_abundance";
		this.m.Name = "Edict of Abundance";
		this.setDescription("It warns of unprecedented impoverishment in forthcoming winters.");
		this.m.Value = 50;
		this.m.EffectText <- "Will induce nearby lairs to stock moderately greater quantities of food, medicines, tools, and treasure in their inventories. This edict's effects are permanent.";
	}
});