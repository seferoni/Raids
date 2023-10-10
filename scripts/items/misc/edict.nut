local Raids = ::RPGR_Raids;
this.edict <- ::inherit("scripts/items/item",
{
    m = {},
	function create()
	{
		this.item.create();
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.Value = 20;
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
		::Sound.play("sounds/.wav", ::Const.Sound.Volume.Inventory);
	}
});