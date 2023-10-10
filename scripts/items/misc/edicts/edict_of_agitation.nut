local Raids = ::RPGR_Raids;
this.edict_of_agitation <- ::inherit("scripts/items/item/misc/edict",
{
    m = {},
	function create()
	{
		this.edict.create();
        this.m.ID = "misc.edict_of_agitation";
		this.m.Name = "Edict of Agitation";
		this.m.Description = "";
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
        local lairs = Raids.Lairs.getCandidatesAtPosition(::World.State.getPlayer().getPos(), 50.0);

        if (lairs.len() == 0)
        {
            Raids.Standard.log("No eligible lair in proximity of the player.");
            return false;
        }

        Raids.Lairs.agitateViableLairs(lairs);
        return true;
	}
});