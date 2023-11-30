local Raids = ::RPGR_Raids;
this.edict_of_retention <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_retention";
		this.m.Name = "Edict of Retention";
		this.setDescription("It speculates on an upsurge of demand for fabled heirlooms of the realm.");
		this.m.Value = 25;
		this.m.ScalingModality = this.m.ScalingModalities.Agitation;
		this.m.EffectText = "Will reduce the chance of nearby lairs clearing famed items within their inventory over time.";
	}
});