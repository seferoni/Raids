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
		this.m.InstructionText = "Right-click to dispatch within proximity of a lair(s). This edict will be consumed in the process.";
	}

	function executeEdictProcedure( _lairs )
	{
		local isFlagOccupied = @(_flag, _lair) Raids.Standard.getFlag(_flag, _lair) != false;

		foreach( lair in _lairs )
		{
			local flag = null;

			if (!isFlagOccupied("EdictContainerA", lair))
			{
				flag = "EdictContainerA";
			}
			else if (!isFlagOccupied("EdictContainerB", lair))
			{
				flag = "EdictContainerB";
			}

			if (flag == null)
			{
				continue;
			}

			Raids.Standard.setFlag(flag, this.getID(), lair);
		}
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
		::Sound.play("sounds/.wav", ::Const.Sound.Volume.Inventory);
	}

	function onUse( _actor, _item = null )
	{
        local lairs = Raids.Lairs.getCandidatesAtPosition(::World.State.getPlayer().getPos(), 50.0);

        if (lairs.len() == 0)
        {
            Raids.Standard.log("No eligible lair in proximity of the player.");
            return false;
        }

        this.executeEdictProcedure(lairs);
        return true;
	}
});