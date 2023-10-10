local Raids = ::RPGR_Raids;
this.edict_of_frugality <- ::inherit("scripts/items/item/misc/edict",
{
    m = {},
	function create()
	{
		this.edict.create();
        this.m.ID = "misc.edict_of_frugality";
		this.m.Name = "Edict of Frugality";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It details patrol schedules and routes of highly organised scouting parties across the realm.";
		this.m.Icon = "consumables/.png";
		this.m.Value = 0;
	}

    function getTooltip()
	{
		local tooltipArray = this.edict.getTooltip();
        return tooltipArray;
	}

    function onUse( _actor, _item = null )
	{

	}
});