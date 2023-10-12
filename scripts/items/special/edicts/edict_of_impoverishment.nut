local Raids = ::RPGR_Raids;
this.edict_of_impoverishment <- ::inherit("scripts/items/special/edict_item",
{
    m = {},
	function create()
	{
		this.edict_item.create();
        this.m.ID = "special.edict_of_impoverishment";
		this.m.Name = "Edict of Impoverishment";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. It maps far-flung locations of supposedly long-abandoned spoils of war littered about the realm.";
		this.m.Value = 100;
        this.m.EffectText <- "Will induce the closest lair to lose resources while preserving the contents of their inventories.";
	}

    function executeEdictProcedure( _lairs )
    {
        this.edict_item.executeEdictProcedure(_lairs);

        foreach( lair in _lairs )
        {
            lair.m.Resources -= ::Math.floor(0.25 * lair.getResources());
            lair.createDefenders();
        }
    }
});