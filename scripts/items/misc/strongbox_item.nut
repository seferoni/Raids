this.strongbox_item <- ::inherit("scripts/items/item", {
    m = {
        Faction = null,
        Tier = null
    },
	function create()
	{
		this.item.create();
		this.m.ID = "misc.strongbox";
		this.m.Name = "Strongbox";
		this.m.Description = "Placeholder";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.Icon = "misc/strongbox.png";
		this.m.IsUsable = true;
    }

	function assignFaction( _faction )
	{
		this.m.Faction = _faction;
	}
});