local Raids = ::RPGR_Raids;
this.edict_of_agitation <- ::inherit("scripts/items/item/misc/edict",
{
    m = {},
	function create()
	{
		this.edict.create();
        this.m.ID = "misc.edict_of_agitation";
		this.m.Name = "Edict of Agitation";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It specifies the date, time, and mustered strength of a scheduled raid.";
		this.m.Icon = "consumables/.png";
		this.m.Value = 0;
	}

    function getTooltip()
	{
		local tooltipArray = this.edict.getTooltip();
        return tooltipArray;
	}

    function executeEdictProcedure( _lairs )
    {
        Raids.Lairs.agitateViableLairs(_lairs);
    }
});