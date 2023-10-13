local Raids = ::RPGR_Raids;
this.official_document_item <- ::inherit("scripts/items/item",
{
    m = {},
	function create()
	{
		this.item.create();
        this.m.ID = "special.official_document_item";
		this.m.Name = "Official Document";
		this.m.Description = "A sealed document. The materials used in its fabrication are rare indeed, but rarer still would be a pair of literate hands to pen its contents.";
		this.m.Value = 150;
		this.m.Icon = "special/official_document_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
        this.m.EffectText <- "Will produce a counterfeit edict, but only if a counterfeiter's tools are present.";
        this.m.InstructionText <- "Right-click to modify its contents.";
	}

    function findCounterfeitingTools()
    {
        local stash = ::World.Assets.getStash().getItems();

        foreach( item in stash )
        {
            if (item != null && item.getID() == "special.counterfeiting_tools_item")
            {
                return true;
            }
        }

        return false;
    }

	function getEffect()
    {
        return this.m.EffectText;
    }

	function getInstruction()
	{
		return this.m.InstructionText;
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

		tooltipArray.extend([
			{id = 6, type = "text", icon = "ui/icons/special.png", text = this.getEffect()},
			{id = 65, type = "text", text = this.getInstruction()}
		]);

		return tooltipArray;
	}

    function playInventorySound( _eventType )
	{
		::Sound.play("sounds/cloth_01.wav", ::Const.Sound.Volume.Inventory);
	}

	function onUse( _actor, _item = null )
	{
        if (!this.findCounterfeitingTools())
        {
            return false;
        }

        ::Sound.play("sounds/scribble.wav", ::Const.Sound.Volume.Inventory);
        ::World.Assets.getStash().add(Raids.Edicts.createEdict());
		::World.Assets.getStash().removeByID("special.counterfeiting_tools_item");
        return true;
	}
});