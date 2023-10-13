local Raids = ::RPGR_Raids;
this.edict_item <- ::inherit("scripts/items/item",
{
    m = {},
	function create()
	{
		this.item.create();
		this.m.Icon = "special/edict_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.InstructionText <- "Right-click to dispatch within proximity of a lair. This edict will be consumed in the process.";
	}

	function executeEdictProcedure( _lair )
	{
		local flag = null,
		isFlagOccupied = @(_flag, _lair) Raids.Standard.getFlag(_flag, _lair) != false;

		if (!isFlagOccupied("EdictContainerA", _lair))
		{
			flag = "EdictContainerA";
		}
		else if (!isFlagOccupied("EdictContainerB", _lair))
		{
			flag = "EdictContainerB";
		}

		if (flag == null)
		{
			return false;
		}

		::Sound.play("sounds/cloth_01.wav", ::Const.Sound.Volume.Inventory);
		Raids.Standard.setFlag(flag, this.getID(), _lair);
		Raids.Standard.setFlag(format("%sTime", flag), ::World.getTime().Days, _lair);
		return true;
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
        local lair = Raids.Lairs.getCandidateAtPosition(::World.State.getPlayer().getPos(), 4000.0);

        if (lair == null)
        {
            Raids.Standard.log("No eligible lair in proximity of the player.");
            return false;
        }

		return this.executeEdictProcedure(lair);
	}
});