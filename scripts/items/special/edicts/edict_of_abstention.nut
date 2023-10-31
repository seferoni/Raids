local Raids = ::RPGR_Raids;
this.edict_of_abstention <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_abstention";
		this.m.Name = "Edict of Abstention";
		this.setDescription("It heralds the arrival of a fresh contingent of troops at a nearby settlement.");
		this.m.Value = 50;
		this.m.EffectText = "Will force nearby lairs into hiding, thereby clearing the roads and allowing for the closest settlement to prosper for a time.";
	}
});