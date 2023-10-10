local Raids = ::RPGR_Raids;
this.edict_of_impoverishment <- ::inherit("scripts/items/item/misc/edict",
{
    m = {},
	function create()
	{
		this.edict.create();
        this.m.ID = "misc.edict_of_impoverishment";
		this.m.Name = "Edict of Impoverishment";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It details the locations of supposedly long-abandoned spoils of war about the realm.";
		this.m.Icon = "consumables/.png";
		this.m.Value = 350;
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

        foreach( lair in lairs )
        {
            lair.m.Resources -= (0.25 * lair.getResources());
        }

        return true;
	}
});