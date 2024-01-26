local Raids = ::RPGR_Raids;
this.edict_of_legibility <- ::inherit("scripts/items/special/edict_item",
{
	m = {},
	function create()
	{
		this.edict_item.create();
		this.m.ID = "special.edict_of_legibility";
		this.m.Name = "Edict of Legibility";
		this.setDescription("It is a functional and accessible treatise on the lingua franca of the realm.");
		this.m.Value = 100;
		this.m.DiscoveryDays = 3;
		this.m.EffectText = "Will permit edicts to be dispatched to nearby lairs inhabited by unconventional factions.";
	}

	function getViableLairs()
	{
		local naiveLairs = Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local Edicts = Raids.Edicts, edictName = Edicts.getEdictName(this.getID()),
		lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (Edicts.findEdict(edictName, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}
});