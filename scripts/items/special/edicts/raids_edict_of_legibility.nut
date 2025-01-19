this.raids_edict_of_legibility <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.raids_edict_item.create();
		this.assignPropertiesByName("Legibility");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.setNativeValue(100);
	}

	function createWarningEntry()
	{
		local compiledString = ::Raids.Strings.getFragmentsAsCompiledString("WarningFragment", "Edicts");
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			compiledString
		);
	}

	function getViableLairs()
	{
		local naiveLairs = ::Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local sugaredID = this.getSugaredID();
		local lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (!_lair.m.IsShowingBanner)
			{
				return false;
			}

			if (::Raids.Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (::Raids.Edicts.findEdict(sugaredID, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}
});