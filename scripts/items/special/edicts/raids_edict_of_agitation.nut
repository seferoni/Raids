this.raids_edict_of_agitation <- ::inherit("scripts/items/special/raids_edict_item",
{
	m = {},
	function create()
	{
		this.raids_edict_item.create();
		this.assignPropertiesByName("Agitation");
	}

	function assignGenericProperties()
	{
		this.raids_edict_item.assignGenericProperties();
		this.setNativeValue(20);
	}

	function createWarningEntry()
	{
		local compiledString = ::Raids.Strings.getFragmentsAsCompiledString("WarningFragment", "Edicts", "Agitation");
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			compiledString
		);
	}

	function getEffectText()
	{
		local text = this.raids_edict_item.getEffectText(); // TODO: use the string handler for this.
		return format(::Raids.Strings.Edicts.Agitation.EffectFragmentA, text, ::Raids.Standard.colourWrap(::Raids.Strings.Edicts.Agitation.EffectFragmentB, ::Raids.Standard.Colour.Green));
	}

	function getViableLairs()
	{
		local naiveLairs = ::Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local self = this;
		local edictName = ::Raids.Edicts.getSugaredID(this.getID());
		local lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (!::Raids.Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (::Raids.Edicts.getOccupiedContainers(_lair).len() == ::Raids.Edicts.Containers.len())
			{
				return false;
			}

			if (!self.isLairViable(_lair))
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

	function isLairViable( _lairObject )
	{
		local agitation = ::Raids.Standard.getFlag("Agitation", _lairObject);
		local descriptors = ::Raids.Lairs.getField("AgitationDescriptors");

		if (agitation == descriptors.Militant)
		{
			return false;
		}

		local tally = 0;
		local containers = ::Raids.Edicts.getOccupiedContainers(_lairObject);

		if (containers.len() == 0)
		{
			return true;
		}

		foreach( container in containers )
		{
			if (::Raids.Standard.getFlag(container, _lairObject) == this.getID())
			{
				tally++;
			}
		}

		if (tally + agitation <= descriptors.Vigilant)
		{
			return true;
		}

		return false;
	}
});
