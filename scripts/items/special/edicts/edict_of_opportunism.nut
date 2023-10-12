local Raids = ::RPGR_Raids;
this.edict_of_opportunism <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_opportunism";
		this.m.Name = "Edict of Opportunism";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It purports to be an official missive promising a large bounty of crowns for a fabled heirloom.";
		this.m.Value = 50;
        this.m.EffectText <- "Will force the closest lair to reassess their inventories and potentially keep more Famed items on hand.";
	}

    function executeEdictProcedure( _lairs )
    {
        this.edict_item.executeEdictProcedure(_lairs);

        foreach( lair in _lairs )
        {
            Raids.Lairs.repopulateLairNamedLoot(lair);
        }
    }
});