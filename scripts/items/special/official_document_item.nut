local Raids = ::RPGR_Raids;
this.official_document_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.m.ID = "special.official_document_item";
		this.m.Name = "Official Document";
		this.m.Description = "A sealed document. The materials used in its fabrication are fairly rare, but rarer still would be a pair of literate hands to pen its contents.";
		this.m.Value = 150;
		this.m.Icon = "special/official_document_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Supply;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.EffectText <- "Will produce a counterfeit Edict upon use. The resulting Edict type can be modulated by a set of writing instruments, if present.";
		this.m.InstructionText <- "Right-click to modify its contents.";
		this.m.Amount = 1;
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

	function getAmount()
	{
		return this.m.Amount;
	}

	function getEffect()
	{
		return this.m.EffectText;
	}

	function getInstruction()
	{
		return this.m.InstructionText;
	}

	function getMasterDocument()
	{
		local items = ::World.Assets.getStash().getItems();

		foreach( item in items )
		{
			if (item != null && item.getID() == this.getID())
			{
				return true;
			}
		}

		return false;
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

	function incrementAmount( _integer = 1 )
	{
		local newAmount = this.getAmount() + _integer;
		this.setAmount(newAmount);
	}

	function isViableForRemoval()
	{
		if (this.getAmount() == 0)
		{
			return true;
		}

		return false;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play("sounds/cloth_01.wav", ::Const.Sound.Volume.Inventory);
	}

	function onAddedToStash( _stashID )
	{
		this.item.onAddedToStash(_stashID);

		if (_stashID != "player")
		{
			return;
		}

		local masterDocument = this.getMasterDocument();

		if (masterDocument == null)
		{
			return;
		}

		masterDocument.incrementAmount();
		::World.Assets.getStash().remove(this);
	}

	function onUse( _actor, _item = null )
	{
		local writingInstruments = this.findWritingInstruments();
		::Sound.play("sounds/scribble.wav", ::Const.Sound.Volume.Inventory);
		::World.Assets.getStash().add(Raids.Edicts.createEdict(writingInstruments));
		this.updateAmountOnUse();

		if (writingInstruments == null)
		{
			return isViableForRemoval();
		}

		if (writingInstruments.getEdictSelectionMode() == writingInstruments.SelectionModes.Indiscriminate)
		{
			return isViableForRemoval();
		}

		this.updateWritingInstruments(writingInstruments);
		return isViableForRemoval();
	}

	function setAmount( _integer )
	{
		this.m.Amount = ::Math.max(0, _integer);
	}

	function updateAmountOnUse()
	{
		this.incrementAmount(-1);
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