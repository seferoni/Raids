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
		this.m.IsCycled <- true;
		this.m.EffectText <- null;
		this.m.InstructionText <- "Right-click to dispatch within proximity of a lair. This edict will be consumed in the process.";
		this.m.TutorialTextCycled <- "Temporary edicts vacate their occupied slot as soon as they are rendered active. Their effects do not persist beyond the next agitation update for a given lair.";
		this.m.TutorialTextPermanent <- "Permanent edicts occupy an edict slot in perpetuity or until removed through special means. Their effects persist beyond agitation updates for a given lair.";
	}

	function executeEdictProcedure( _lairs )
	{	// TODO: this should also look within history
		local isContainerVacant = @(_container, _lair) !Raids.Standard.getFlag(_container, _lair),
		isValid = false;

		foreach( lair in _lairs )
		{
			local container = null;

			if (Raids.Edicts.findEdict(this.getID(), lair) != false)
			{
				continue;
			}

			if (Raids.Edicts.findEdictInHistory(Raids.Edicts.getEdictName(this.getID()), lair) != false)
			{
				continue;
			}

			if (isContainerVacant("EdictContainerA", lair))
			{
				container = "EdictContainerA";
			}
			else if (isContainerVacant("EdictContainerB", lair))
			{
				container = "EdictContainerB";
			}

			if (container == null)
			{
				continue;
			}

			Raids.Standard.setFlag(container, this.getID(), lair);
			Raids.Standard.setFlag(format("%sTime", container), ::World.getTime().Days, lair);
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
		];

		if (Raids.Standard.getSetting("ShowTutorial"))
		{
			tooltipArray.push({id = 6, type = "text", icon = "ui/icons/warning.png", text = this.getTutorial()})
		}

		tooltipArray.push({id = 65, type = "text", text = this.getInstruction()});
		return tooltipArray;
	}

	function getViableLairs()
	{
		local naiveLairs = Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local ID = this.getID(), Edicts = Raids.Edicts,
		lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (!Edicts.isLairViable(_lair))
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