this.edict_of_agitation <- ::inherit("scripts/items/special/raids_edict_item",
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

	function createWarningEntry()
	{
		# Define entry from template.
		local entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.Warning;

		# Define colour wrap lambda to ease readability.
		local colourWrap = @(_string) ::Raids.Standard.colourWrap(_string, ::Raids.Standard.Colour.Red);

		# Create sentence fragments for text field.
		local fragmentA = format("There are no %s.", colourWrap("viable lairs within proximity"));

		# Highlight sections of text most relevant to a prospective reader.
		local fragmentB =  format("Edicts of Agitation target lairs %s.", colourWrap("below the maximally Agitated state"));

		# Concatenate fragments.
		entry.text = format("%s %s", fragmentA, fragmentB);

		return entry;
	}

	function getEffectText()
	{
		local text = this.edict_item.getEffectText();
		return format("%s This Edict can occupy %s.", text, ::Raids.Standard.colourWrap("multiple slots at once", ::Raids.Standard.Colour.Green));
	}

	function getViableLairs()
	{
		local naiveLairs = ::Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local self = this,
		edictName = ::Raids.Edicts.getEdictName(this.getID()),
		lairs = naiveLairs.filter(function( _index, _lair )
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

		if (agitation == ::Raids.Lairs.AgitationDescriptors.Militant)
		{
			return false;
		}

		local tally = 0,
		containers = ::Raids.Edicts.getOccupiedContainers(_lairObject);

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

		if (tally + agitation <= ::Raids.Lairs.AgitationDescriptors.Vigilant)
		{
			return true;
		}

		return false;
	}

	function isCycled()
	{
		return true;
	}
});
