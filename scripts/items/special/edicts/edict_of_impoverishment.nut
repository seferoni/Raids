local Raids = ::RPGR_Raids;
this.edict_of_impoverishment <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_impoverishment";
		this.m.Name = "Edict of Impoverishment";
		this.setDescription("It maps far-flung locations of supposedly long-abandoned spoils of war littered about the realm.");
		this.m.Value = 100;
        this.m.EffectText <- "Will induce the closest lair to lose resources while preserving the contents of their inventories. This edict's effects are temporary.";
	}
});