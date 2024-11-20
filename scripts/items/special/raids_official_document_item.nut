this.raids_official_document_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	Sounds =
	{
		Move = "sounds/cloth_01.wav",
		Use = "sounds/cloth_01.wav",
	},
	function create()
	{
		this.item.create();
		this.m.ID = "special.official_document_item";
		this.m.Name = "Official Document";
		this.m.Description = "A sealed document. The materials used in its fabrication are fairly rare, but rarer still would be a pair of literate hands to pen its contents.";
		this.m.Value = 150;
		this.m.Icon = "special/official_document_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.EffectText <- "Will produce a counterfeit Edict upon use. The resulting Edict type can be modulated by a set of writing instruments, if present.";
		this.m.Instruction <- "Right-click to modify its contents.";
	}

	function findWritingInstruments()
	{
		local candidates = ::World.Assets.getStash().getItems().filter(@(_index, _item) _item != null && _item.getID() == "misc.writing_instruments_item");

		if (candidates.len() == 0)
		{
			return null;
		}

		foreach( candidate in candidates )
		{
			local selectionMode = candidate.getEdictSelectionMode();

			if (selectionMode != candidate.SelectionModes.Indiscriminate)
			{
				return candidate;
			}
		}

		return candidates[0];
	}

	function getEffect()
	{
		return this.m.EffectText;
	}

	function getInstruction()
	{
		return this.m.Instruction;
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
		push({id = 6, type = "text", icon = "ui/icons/special.png", text = this.getEffect()});

		# Create instruction entry.
		push({id = 65, type = "text", text = this.getInstruction()});

		return tooltipArray;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play(this.Sounds.Move, ::Const.Sound.Volume.Inventory);
	}

	function playUseSound()
	{
		::Sound.play(this.Sounds.Use, ::Const.Sound.Volume.Inventory);
	}

	function onUse( _actor, _item = null )
	{
		# Find writing instruments in player stash.
		local writingInstruments = this.findWritingInstruments();

		# Play use sound.
		this.playUseSound();

		# Create and add produced Edict to stash.
		::World.Assets.getStash().add(::Raids.Edicts.createEdict(writingInstruments));

		# Terminate execution if there are no writing instruments.
		if (writingInstruments == null)
		{
			return true;
		}

		# Terminate execution if the writing instruments item first in queue is set to indiscriminate Edict selection.
		if (writingInstruments.getEdictSelectionMode() == writingInstruments.SelectionModes.Indiscriminate)
		{
			return true;
		}

		# Reduce number of uses for the writing instruments item first in queue.
		this.updateWritingInstruments(writingInstruments);
		return true;
	}

	function updateWritingInstruments( _writingInstruments )
	{
		local remainingUses = _writingInstruments.getUses();

		if (remainingUses == 1)
		{
			::World.Assets.getStash().remove(_writingInstruments);
			return;
		}

		_writingInstruments.setUses(remainingUses - 1);
	}
});