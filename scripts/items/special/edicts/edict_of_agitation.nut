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
		this.m.EffectText = "Will Agitate nearby lairs.";
	}

	function getViableLairs()
	{
		local naiveLairs = Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local edictName = Raids.Edicts.getEdictName(this.getID()),
		lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (!Raids.Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (Raids.Standard.getFlag("Agitation", _lair) == Raids.Lairs.AgitationDescriptors.Militant)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

	function isCycled()
	{
		return true;
	}
});