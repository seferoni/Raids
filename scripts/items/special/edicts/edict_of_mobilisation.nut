local Raids = ::RPGR_Raids;
this.edict_of_mobilisation <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_mobilisation";
		this.m.Name = "Edict of Mobilisation";
		this.setDescription("It warns of an imminent shortage of manpower for the safeguarding of local settlements and holdings.");
		this.m.Value = 25;
		this.m.DiscoveryDays = 1;
		this.m.EffectText = "Will significantly reduce the time taken for nearby lairs to mobilise fresh parties.";
	}
});