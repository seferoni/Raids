this.strongbox_item <- ::inherit("scripts/items/item", {
    m = {
        Faction = null,
        Tier = null,
		TierDescriptors =
		{
			Gilded = 1,
			Bountiful = 2,
			Middling = 3,
			Enfeebled = 4
		}
    },
	function create()
	{
		this.item.create();
		this.m.ID = "misc.strongbox";
		this.m.Name = "Strongbox";
		this.m.Description = "A strange container, contents indiscernible. ";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.Icon = "misc/strongbox.png";
		this.m.IsUsable = true;
    }

	function getFaction()
	{
		return this.m.Faction;
	}

	function setFaction( _faction )
	{
		this.m.Faction = _faction;
	}

	function getTier()
	{
		return this.m.Tier;
	}

	function setTier( _tier )
	{
		this.m.Tier = _tier;
	}

	function setTierOnAdded( _resources )
	{
		local randomNumber = ::Math.rand(0, 100);
		this.setTier(randomNumber <= 10 ? this.m.TierDescriptors.Gilded : randomNumber <= 35 ? this.m.TierDescriptors.Bountiful : randomNumber <= 75 ? this.m.TierDescriptors.Middling : this.m.TierDescriptors.Enfeebled);
	}

	function setNameOnAdded()
	{
		local tierDescriptor = ::RPGR_Raids.getDescriptor(this.getTier(), this.m.TierDescriptors);

		if (this.getFaction == null)
		{
			this.m.Name = tierDescriptor + " " + this.m.Name;
			return;
		}

		local factionDescriptor = ::RGPR_Raids.getDescriptor(this.getFaction(), gt.Const.Factions);
		this.m.Name = tierDescriptor + " " + factionDescriptor + " " + this.m.Name;
	}

	function retrieveLootByTier( _tier )
	{

	}

});