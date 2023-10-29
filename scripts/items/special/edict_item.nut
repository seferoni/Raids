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
		this.m.IsCycled = true;
		this.m.TutorialTextCycled <- "Temporary edicts vacate their occupied slot as soon as they are rendered active. Their effects do not persist beyond the next agitation update for a given lair.";
		this.m.TutorialTextPermanent <- "Permanent edicts occupy an edict slot in perpetuity unless removed through special means. Their effects persist beyond agitation updates for a given lair.";
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
		return format("%s This edict's effects are %s.", this.m.EffectText, this.m.IsCycled ? "temporary" : "permanent");
    }

	function getInstruction()
	{
		return this.m.InstructionText;
	}

	function getTutorial()
	{
		if (this.m.IsCycled) return this.m.TutorialTextCycled;
		return this.m.TutorialTextPermanent;
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
			{id = 65, type = "text", icon = "ui/icons/warning.png", text = this.getTutorial()},
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

		local ID = this.getID(), Edicts = Raids.Edicts;
		lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (Edicts.findEdict(ID, _lair) != false)
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