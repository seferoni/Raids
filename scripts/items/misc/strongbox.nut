this.strongbox <- ::inherit("scripts/items/item", {
    m = {
        Faction = null,
        Tier = null
    },
	function create()
	{
		this.item.create();
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsUsable = true;
    }
});