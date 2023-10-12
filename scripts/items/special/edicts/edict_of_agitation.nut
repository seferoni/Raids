local Raids = ::RPGR_Raids;
this.edict_of_agitation <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_agitation";
		this.m.Name = "Edict of Agitation";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It specifies the date, time, and mustered strength of a scheduled raid.";
		this.m.Value = 20;
		this.m.EffectText <- "Will agitate the closest nearby lair.";
	}

    function executeEdictProcedure( _lairs )
    {
		this.edict_item.executeEdictProcedure(_lairs);
        Raids.Lairs.agitateViableLairs(_lairs);
    }
});