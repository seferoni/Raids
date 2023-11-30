local Raids = ::RPGR_Raids;
this.edict_of_agitation <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_agitation";
		this.m.Name = "Edict of Agitation";
		this.setDescription("It specifies the date, time, and mustered strength of a scheduled raid.");
		this.m.Value = 20;
		this.m.EffectText = "Will agitate nearby lairs.";
	}

	function getViableLairs()
	{
		local Raids = ::RPGR_Raids,
		naiveLairs = this.edict_item.getViableLairs();

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local lairs = naiveLairs.filter(@(_index, _lair) Raids.Standard.getFlag("Agitation", _lair) != Raids.Lairs.AgitationDescriptors.Militant);
		return lairs;
	}
});