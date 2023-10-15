local Raids = ::RPGR_Raids;
this.counterfeiting_tools_item <- ::inherit("scripts/items/item",
{
    m = {},
	function create()
	{
		this.item.create();
        this.m.ID = "special.counterfeiting_tools_item";
		this.m.Name = "Official Document";
		this.m.Description = "An assortment of tools specialised for use in the forgery of noble house seals. Included is a quarter of a quire of gossamer paper, a quill pen fashioned from goose feathers, a filled inkwell, some beeswax, and an imitation wax seal.";
		this.m.Value = 300;
		this.m.Icon = "special/counterfeiting_tools_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = false;
	}

    function getTooltip()
	{
		local tooltipArray =
		[
			{id = 1, type = "title", text = this.getName()},
			{id = 2, type = "description", text = this.getDescription()},
			{id = 66, type = "text", text = this.getValueString()}
		];

		if (this.getIconLarge() != null)
		{
			tooltipArray.push({id = 3, type = "image", image = this.getIconLarge(), isLarge = true});
		}
		else
		{
			tooltipArray.push({id = 3, type = "image", image = this.getIcon()});
		}

		return tooltipArray;
	}

    function playInventorySound( _eventType )
	{
		::Sound.play("sounds/move_pot_clay_01.wav", ::Const.Sound.Volume.Inventory);
	}
});