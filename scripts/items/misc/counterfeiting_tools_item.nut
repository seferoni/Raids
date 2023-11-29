local Raids = ::RPGR_Raids;
this.counterfeiting_tools_item <- ::inherit("scripts/items/item",
{
    m = {
		MaximumUses = 3
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
		this.setUses(this.m.MaximumUses);
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
			{id = 66, type = "text", text = this.getValueString()},
			{id = 3, type = "image", image = this.getIcon()}
		];

		return tooltipArray;
	}

	function getUses()
	{
		return Raids.Standard.getFlag("Uses", this);
	}
	
	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		this.m.Flags.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.Flags.onDeserialize(_in);
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