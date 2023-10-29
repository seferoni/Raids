local Raids = ::RPGR_Raids;
this.edict_of_opportunism <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_opportunism";
		this.m.Name = "Edict of Opportunism";
		this.setDescription("It purports to be an official missive promising a handsome bounty of crowns for a fabled heirloom.");
		this.m.Value = 50;
        this.m.EffectText <- "Will induce nearby lairs to reassess their inventories and potentially keep more Famed items on hand.";
	}
});