local Raids = ::RPGR_Raids;
this.edict_of_opportunism <- ::inherit("scripts/items/item/misc/edict",
{
    m = {},
	function create()
	{
		this.edict.create();
        this.m.ID = "misc.edict_of_opportunism";
		this.m.Name = "Edict of Opportunism";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It purports to be an official missive promising a large bounty of crowns for a fabled heirloom.";
		this.m.Icon = "consumables/.png";
		this.m.Value = 50;
        this.m.EffectText = "Will force nearby lairs to reassess their inventories and potentially keep more Famed items on hand.";
	}

    function getTooltip()
	{
		local tooltipArray = this.edict.getTooltip();
        return tooltipArray;
	}

    function executeEdictProcedure( _lairs )
    {
        this.edict.executeEdictProcedure(_lairs);

        foreach( lair in _lairs )
        {
            Raids.Lairs.repopulateLairNamedLoot(lair);
        }
    }
});