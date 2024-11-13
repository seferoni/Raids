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
		this.m.EffectText = "Will permit Edicts to be dispatched to nearby lairs inhabited by unconventional factions.";
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
		local fragmentB =  format("Edicts of Legibility target lairs occupied by factions such as %s.", colourWrap("goblins, orcs, and ancient undead"));

		# Concatenate fragments.
		entry.text = format("%s %s", fragmentA, fragmentB);

		return entry;
	}

	function getViableLairs()
	{
		local naiveLairs = ::Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local edictName = ::Raids.Edicts.getEdictName(this.getID()),
		lairs = naiveLairs.filter(function( _index, _lair )
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