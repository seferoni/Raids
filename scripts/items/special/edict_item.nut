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

	function executeEdictProcedure( _lairs )
	{
		local isFlagOccupied = @(_flag, _lair) Raids.Standard.getFlag(_flag, _lair) != false, 
		isValid = false;

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
			Raids.Standard.setFlag(format("%sTime", flag), ::World.getTime().Days, lair);
			if (!isValid) isValid = true;
		}

		if (!isValid) return false;
		::Sound.play("sounds/cloth_01.wav", ::Const.Sound.Volume.Inventory);
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
			{id = 66, type = "text", text = this.getValueString()},
			{id = 3, type = "image", image = this.getIcon()},
			{id = 6, type = "text", icon = "ui/icons/special.png", text = this.getEffect()},
			{id = 65, type = "text", text = this.getInstruction()}
		];

		return tooltipArray;
	}

	function getViableLairs()
	{
		local naiveLairs = Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local ID = this.getID(), 
		lairs = naiveLairs.filter(function( _index, _lair ) 
		{
			local factionType = ::World.FactionManager.getFaction(_lair.getFaction()).getType();

			if (Raids.Edicts.Factions.find(factionType) == null)
			{
				return false;
			}

			if (Raids.Edicts.findEdict(ID, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

    function playInventorySound( _eventType )
	{
		::Sound.play("sounds/cloth_01.wav", ::Const.Sound.Volume.Inventory);
	}

	function setDescription( _string )
	{
		this.m.Description = format("A thoroughly illegal facsimile of official correspondence. %s", _string);
	}

	function onUse( _actor, _item = null )
	{
		local lairs = this.getViableLairs();

		if (lairs.len() == 0)
		{
			return false;
		} 

		return this.executeEdictProcedure(lairs);
	}
});