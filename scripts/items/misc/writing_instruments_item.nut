local Raids = ::RPGR_Raids;
this.writing_instruments_item <- ::inherit("scripts/items/item",
{
	m =
	{
		MaximumUses = 3,
	},
	SelectionModes =
	{
		Indiscriminate = 1,
		Selective = 2,
		Inverted = 3
	},
	Sounds =
	[
		"sounds/raids.paper_01.wav",
		"sounds/raids.paper_02.wav",
		"sounds/raids.paper_03.wav"
	],
	Tooltip =
	{
		Icons =
		{
			Selection = "ui/icons/special.png",
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
	function create()
	{
		this.item.create();
		this.m.Flags <- ::new("scripts/tools/tag_collection");
		this.m.ID = "misc.writing_instruments_item";
		this.m.Name = "Writing Instruments";
		this.m.Description = "A conventional assortment of writing instruments, fit for any itinerant scribe. Included is a quarter of a quire of gossamer paper, a quill pen fashioned from goose feathers, a filled inkwell, some beeswax, and a wax seal.";
		this.m.Value = 300;
		this.m.Icon = "misc/writing_instruments_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.initialiseEdictSelection();
		this.setUses(this.m.MaximumUses);
		this.m.InstructionText <- "Right-click to cycle between different selection modes.";
	}

	function createQueueEntry()
	{
		local entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.Warning;
		entry.text = "This item's Edict selection preferences take precedence.";
		return entry;
	}

	function getEdictCandidates()
	{
		local edicts = Raids.Edicts.getEdictFiles(),
		selectedEdicts = [];

		while (selectedEdicts.len() < Raids.Edicts.Internal.EdictSelectionSize)
		{
			local candidate = edicts[::Math.rand(0, edicts.len() - 1)];

			if (selectedEdicts.find(candidate) != null)
			{
				continue;
			}

			selectedEdicts.push(candidate);
		}

		return selectedEdicts;
	}

	function getEdictSelection()
	{
		return Raids.Standard.getFlag("EdictSelection", this);
	}

	function getEdictSelectionAsArray()
	{
		local selectionArray = split(this.getEdictSelection(), ",").map(@(_edictName) strip(_edictName));
		return selectionArray;
	}

	function getEdictSelectionAsFiles()
	{
		local Edicts = Raids.Edicts,
		toFileName = @(_array) _array.map(@(_edictName) Edicts.getEdictFileName(_edictName)),
		selectionMode = this.getEdictSelectionMode();

		switch (selectionMode)
		{
			case this.SelectionModes.Indiscriminate: return Edicts.getEdictFiles();
			case this.SelectionModes.Selective: return toFileName(this.getEdictSelectionAsArray());
			case this.SelectionModes.Inverted:
			{
				local edictFiles = Edicts.getEdictFiles();
				Raids.Standard.removeFromArray(toFileName(this.getEdictSelectionAsArray()), edictFiles);
				return edictFiles;
			}
		}
	}

	function getEdictSelectionMode()
	{
		return Raids.Standard.getFlag("EdictSelectionMode", this);
	}

	function getEdictSelectionText()
	{
		local selectionMode = this.getEdictSelectionMode();

		if (selectionMode != this.SelectionModes.Indiscriminate)
		{
			local selection = Raids.Standard.colourWrap(this.getEdictSelection(), format("%sValue", selectionMode == this.SelectionModes.Selective ? "Positive" : "Negative"));
			return format("%s: %s", Raids.Standard.getDescriptor(selectionMode, this.SelectionModes), selection);
		}

		return Raids.Standard.getDescriptor(selectionMode, this.SelectionModes);
	}

	function getFlags()
	{
		return this.m.Flags;
	}

	function getInstruction()
	{
		return this.m.InstructionText;
	}

	function isFirstInQueue()
	{
		# Prepare variables in local environment.
		local candidates = ::World.Assets.getStash().getItems().filter(@(_index, _item) _item != null && _item.getID() == "misc.writing_instruments_item");

		# Handle case where the current object is the only valid instance.
		if (candidates.len() == 1)
		{	# In the case that there are no other valid instances, hide queue entry.
			return false;
		}

		# Find position of object in queue.
		local currentPosition = candidates.find(this);

		# Get current Edict selection mode.
		local selectionMode = this.getEdictSelection();

		# Handle case where object is unequivocally not first in queue. This evaluation relaxes the range of indices iterated over in the succeeding conditions.
		if (selectionMode == this.SelectionModes.Indiscriminate && currentPosition != 0)
		{
			return false;
		}

		# Prepare variables for the case of a non-indiscriminate selection mode.
		local originIndex = 0,
		thresholdIndex = currentPosition;

		# Handle case where selection mode is indiscriminate.
		if (selectionMode == this.SelectionModes.Indiscriminate)
		{
			originIndex = currentPosition;
			thresholdIndex = candidates.len();
		}

		# Process candidates in queue as appropriate.
		for( local i = originIndex; i < indexThreshold; i++ )
		{
			if (candidates[i].getEdictSelectionMode() != this.SelectionModes.Indiscriminate)
			{
				return false;
			}
		}

		return true;
	}

	function getTooltip()
	{
		# Prepare variables in local environment.
		local tooltipArray = [],
		push = @(_entry) tooltipArray.push(_entry);

		# Create generic entries.
		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		push({id = 66, type = "text", text = this.getValueString()});
		push({id = 3, type = "image", image = this.getIcon()});

		# Create warning entry.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Warning, text = format("Has %s uses remaining.", Raids.Standard.colourWrap(this.getUses(), "NegativeValue"))});

		# Evaluate if this instance is queued first.
		if (this.isFirstInQueue())
		{	# Create queue entry.
			push(this.createQueueEntry());
		}

		# Create selection mode entry.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Selection, text = this.getEdictSelectionText()});

		# Create instruction entry.
		push({id = 65, type = "text", text = this.getInstruction()});

		return tooltipArray;
	}

	function getUses()
	{
		return Raids.Standard.getFlag("Uses", this);
	}

	function initialiseEdictSelection()
	{
		local Edicts = Raids.Edicts,
		edictCandidates = this.getEdictCandidates().map(@(_filePath) Edicts.getEdictName(_filePath, true)),
		selection = "";

		foreach( edictName in edictCandidates )
		{
			selection = Raids.Standard.appendToStringList(selection, edictName);
		}

		Raids.Standard.setFlag("EdictSelection", selection, this);
		Raids.Standard.setFlag("EdictSelectionMode", this.SelectionModes.Indiscriminate, this);
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.Flags.onDeserialize(_in);
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		this.m.Flags.onSerialize(_out);
	}

	function onUse( _actor, _item = null )
	{
		local selectionMode = this.getEdictSelectionMode();

		if (selectionMode == this.SelectionModes.Inverted)
		{
			selectionMode = this.SelectionModes.Indiscriminate;
		}
		else
		{
			selectionMode += 1;
		}

		this.setEdictSelectionMode(selectionMode);
		this.playUseSound();
		::Tooltip.reload();
		return false;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play("sounds/move_pot_clay_01.wav", ::Const.Sound.Volume.Inventory);
	}

	function playUseSound()
	{
		::Sound.play(this.Sounds[::Math.rand(0, this.Sounds.len() - 1)], ::Const.Sound.Volume.Inventory);
	}

	function setEdictSelection( _selection )
	{
		Raids.Standard.setFlag("EdictSelection", _selection, this);
	}

	function setEdictSelectionMode( _selectionMode )
	{
		Raids.Standard.setFlag("EdictSelectionMode", _selectionMode, this);
	}

	function setUses( _integer )
	{
		Raids.Standard.setFlag("Uses", _integer, this);
	}
});