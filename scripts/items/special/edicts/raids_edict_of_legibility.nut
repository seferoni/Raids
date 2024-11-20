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
		this.m.Value = 100;
	}

	function createWarningEntry()
	{
		local colourWrap = @(_string) ::Raids.Standard.colourWrap(_string, ::Raids.Standard.Colour.Red);
		local fragmentA = format(::Raids.Strings.Edicts.LegibilityWarningFragmentA, colourWrap(::Raids.Strings.Edicts.LegibilityWarningFragmentB));
		local fragmentB =  format(::Raids.Strings.Edicts.LegibilityWarningFragmentC, colourWrap(::Raids.Strings.Edicts.LegibilityWarningFragmentD));
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			format("%s %s", fragmentA, fragmentB)
		);
	}

	function getViableLairs()
	{
		local naiveLairs = ::Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local edictName = ::Raids.Edicts.getSugaredID(this.getID()); // TODO: again with the edict name?
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

			if (::Raids.Edicts.findEdict(edictName, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}
});