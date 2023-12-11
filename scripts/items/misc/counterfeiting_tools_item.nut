local Raids = ::RPGR_Raids;
this.counterfeiting_tools_item <- ::inherit("scripts/items/item",
{
	m = {
		MaximumUses = 3,
		SelectionModes = {Indiscriminate = 1, Selective = 2, Inverted = 3}
	},
	function create()
	{
		this.item.create();
		this.m.Flags <- ::new("scripts/tools/tag_collection");
		this.m.ID = "misc.counterfeiting_tools_item";
		this.m.Name = "Counterfeiting Tools";
		this.m.Description = "An assortment of tools specialised for use in the forgery of noble house seals. Included is a quarter of a quire of gossamer paper, a quill pen fashioned from goose feathers, a filled inkwell, some beeswax, and an imitation wax seal.";
		this.m.Value = 300;
		this.m.Icon = "misc/counterfeiting_tools_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Supply | ::Const.Items.ItemType.Crafting;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = false;
		this.initialiseEdictSelection();
		this.setUses(this.m.MaximumUses);
	}

	function getEdictCandidates()
	{
		local edicts = Raids.Edicts.getEdictFiles(),
		selectedEdicts = [];

		while (selectedEdicts.len() <= Raids.Internal.EdictSelectionSize)
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

	function getEdictSelectionMode()
	{
		return Raids.Standard.getFlag("EdictSelectionMode", this);
	}

	function getEdictSelectionText()
	{
		local selectionMode = this.getEdictSelectionMode();

		if (selectionMode == this.SelectionModes.Selective)
		{
			local selection = this.getEdictSelection();
			return format("Selective: %s", Raids.Standard.colourWrap(selection, "NegativeValue"));
		}

		return Raids.Standard.getDescriptor(selectionMode, this.SelectionModes);
	}

	function getFlags()
	{
		return this.m.Flags;
	}

	function getTooltip()
	{
		local tooltipArray =
		[
			{id = 1, type = "title", text = this.getName()},
			{id = 2, type = "description", text = this.getDescription()},
			{id = 6, type = "text", icon = "ui/icons/warning.png", text = format("Has %s uses remaining.", Raids.Standard.colourWrap(this.getUses(), "NegativeValue"))},
			{id = 6, type = "text", icon = "ui/icons/special.png", text = this.getEdictSelectionText()},
			{id = 66, type = "text", text = this.getValueString()},
			{id = 3, type = "image", image = this.getIcon()}
		];

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
			Raids.Standard.appendToString(selection, edictName);
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
		return false;
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

	function playInventorySound( _eventType )
	{
		::Sound.play("sounds/move_pot_clay_01.wav", ::Const.Sound.Volume.Inventory);
	}
});