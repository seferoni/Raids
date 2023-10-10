local Raids = ::RPGR_Raids;
this.edict_of_stasis <- ::inherit("scripts/items/item/misc/edict",
{
    m = {},
	function create()
	{
		this.edict.create();
        this.m.ID = "misc.edict_of_stasis";
		this.m.Name = "Edict of Stasis";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It outlines a novel long-term strategy that involves targeted, small-scale attacks and coordinated ambushes.";
		this.m.Icon = "consumables/.png";
		this.m.Value = 50;
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

	}
});