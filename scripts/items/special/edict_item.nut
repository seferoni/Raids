local Raids = ::RPGR_Raids;
this.edict_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.m.Icon = "special/edict_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.DiscoveryDays <- 1;
		this.m.ScalingModality <- this.ScalingModalities.Static;
		this.m.EffectText <- null;
		this.m.InstructionText <- "Right-click to dispatch within proximity of a lair. This Edict will be consumed in the process.";
		this.m.ShowWarning <- false;
	},
	ScalingModalities = 
	{
		Static = 0,
		Agitation = 1, 
		Resources = 2
	},
	Sounds = 
	{
		Move = "sounds/cloth_01.wav",
		Use = "sounds/cloth_01.wav",
		Warning = "sounds/move_pot_clay_01.wav"
	},
	Tooltip =
	{
		Icons =
		{
			Effect = "ui/icons/special.png",
			Discovery = "ui/icons/action_points.png",
			Persistence = "ui/icons/scroll_01.png",
			Scaling = "ui/icons/level.png",
			Warning = "ui/icons/warning.png"
		},
		Template =
		{
			id = 6,
			type = "text",
			icon = "",
			text = ""
		}
	}

	function createWarningEntry()
	{
		# Define entry from template.
		local entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.Warning;

		# Define colour wrap lambda to ease readability.
		local Standard = Raids.Standard,
		colourWrap = @(_string) Standard.colourWrap(_string, Standard.Colour.Red);

		# Create sentence fragments for text field.
		local fragmentA = format("There are no %s.", colourWrap("viable lairs within proximity"));

		# Highlight sections of text most relevant to a prospective reader.
		local fragmentB =  format("Lairs that are viable and within proximity %s.", colourWrap("will display Edict slots on their tooltip"));

		# Concatenate fragments.
		entry.text = format("%s %s", fragmentA, fragmentB);

		return entry;
	}

	function executeEdictProcedure( _lairs )
	{
		local isValid = false;

		foreach( lair in _lairs )
		{
			local vacantContainers = clone Raids.Edicts.Containers;
			Raids.Standard.removeFromArray(Raids.Edicts.getOccupiedContainers(lair), vacantContainers);

			if (vacantContainers.len() == 0)
			{
				continue;
			}

			this.initialiseContainer(vacantContainers[0], lair);

			if (!isValid)
			{
				isValid = true;
			}
		}

		if (!isValid)
		{
			return false;
		} 
		
		this.playUseSound();
		return true;
	}

	function getDiscoveryDuration()
	{
		return this.m.DiscoveryDays;
	}

	function getDiscoveryText()
	{
		local discoveryDuration = this.getDiscoveryDuration(),
		discoveryText = Raids.Standard.colourWrap(discoveryDuration, Raids.Standard.Colour.Green);
		return format("This edict takes effect in %s %s.", discoveryText, discoveryDuration > 1 ? "days" : "day");
	}

	function getEffectText()
	{
		return this.m.EffectText;
	}

	function getInstructionText()
	{
		return this.m.InstructionText;
	}

	function getPersistenceText()
	{
		local descriptor = Raids.Standard.colourWrap(this.isCycled() ? "temporary" : "permanent", Raids.Standard.Colour.Red);
		return format("This edict's effects are %s.", descriptor);
	}

	function getScalingModality()
	{
		return this.m.ScalingModality;
	}

	function getScalingText()
	{
		local scaling = this.m.ScalingModality, modalities = this.ScalingModalities;
		if (scaling == modalities.Static) return format("This edict's effects are %s.", Raids.Standard.colourWrap("static", Raids.Standard.Colour.Green));
		return format("This edict's effects scale with lair %s.", Raids.Standard.colourWrap(scaling == modalities.Agitation ? "Agitation" : "resources", Raids.Standard.Colour.Red));
	}

	function getTooltip()
	{
		local tooltipArray = [],
		push = @(_entry) tooltipArray.push(_entry);

		# Create generic entries.
		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		push({id = 66, type = "text", text = this.getValueString()});
		push({id = 3, type = "image", image = this.getIcon()});

		# Create effect entry.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Effect, text = this.getEffectText()});

		# Create persistence entry.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Persistence, text = this.getPersistenceText()});

		# Create discovery time entry.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Discovery, text = this.getDiscoveryText()});

		# Create scaling modality entry.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Scaling, text = this.getScalingText()});

		# Evaluate viability for appending warning entry.
		if (this.getWarningState())
		{	# Create warning entry.
			push(this.createWarningEntry());

			# Reset warning state.
			this.setWarningState(false);
		}

		# Create hint entry.
		push({id = 65, type = "text", text = this.getInstructionText()});

		return tooltipArray;
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
			if (!Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (Edicts.findEdict(edictName, _lair) != false)
			{
				return false;
			}

			if (Edicts.findEdictInHistory(edictName, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

	function getWarningState()
	{
		return this.m.ShowWarning;
	}

	function initialiseContainer( _container, _lair )
	{
		Raids.Standard.setFlag(_container, this.getID(), _lair);
		Raids.Standard.setFlag(format("%sTime", _container), ::World.getTime().Days, _lair);
		Raids.Standard.setFlag(format("%sDuration", _container), this.getDiscoveryDuration(), _lair);
	}

	function isCycled()
	{
		return Raids.Edicts.CycledEdicts.find(Raids.Edicts.getEdictName(this.getID())) != null;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play(this.Sounds.Move, ::Const.Sound.Volume.Inventory);
	}

	function playUseSound()
	{
		::Sound.play(this.Sounds.Use, ::Const.Sound.Volume.Inventory);
	}

	function playWarningSound()
	{
		::Sound.play(this.Sounds.Warning, ::Const.Sound.Volume.Inventory);
	}

	function setWarningState( _bool )
	{
		this.m.ShowWarning = _bool;
	}

	function setDescription( _string )
	{
		this.m.Description = format("A thoroughly illegal facsimile of official correspondence. %s", _string);
	}

	function onUse( _actor, _item = null )
	{
		local lairs = this.getViableLairs();

		if (lairs.len() == 0)
		{
			this.setWarningState(true);
			this.playWarningSound();
			::Tooltip.reload();
			return false;
		}

		return this.executeEdictProcedure(lairs);
	}
});