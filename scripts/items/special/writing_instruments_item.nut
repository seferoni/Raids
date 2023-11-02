local Raids = ::RPGR_Raids;
this.writing_instruments_item <- ::inherit("scripts/items/item",
{
    m = {},
	function create()
	{
		this.item.create();
        this.m.ID = "special.writing_instruments_item";
		this.m.Name = "Writing Instruments";
		this.m.Description = "A conventional assortment of writing instruments, fit for any itinerant scribe. Included is a quarter of a quire of gossamer paper, a quill pen fashioned from goose feathers, and a filled inkwell.";
		this.m.Value = 500;
		this.m.Icon = "special/writing_instruments_item.png";
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
			{id = 66, type = "text", text = this.getValueString()},
			{id = 3, type = "image", image = this.getIcon()}
		];

		return tooltipArray;
	}

    function playInventorySound( _eventType )
	{
		::Sound.play("sounds/move_pot_clay_01.wav", ::Const.Sound.Volume.Inventory);
	}
});