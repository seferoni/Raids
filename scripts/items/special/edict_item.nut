local Raids = ::RPGR_Raids;
this.edict_item <- ::inherit("scripts/items/item",
{
	m = 
	{
		ScalingModalities = {Static = 0, Agitation = 1, Resources = 2}
	},
	function create()
	{
		this.item.create();
		this.m.Icon = "special/edict_item.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.DiscoveryDays <- 2;
		this.m.ScalingModality <- this.m.ScalingModalities.Static;
		this.m.EffectText <- null;
		this.m.InstructionText <- "Right-click to dispatch within proximity of a lair. This edict will be consumed in the process.";
	}

	function executeEdictProcedure( _lairs )
	{
		local isValid = false;
		
		foreach( lair in _lairs )
		{
			local vacantContainers = clone Raids.Edicts.Containers;
			Raids.Standard.removeFromArray(Raids.Edicts.getOccupiedContainers(lair), vacantContainers);

			if (vacantContainers.len() == 0)
			{
				continue;
			}

			local container = vacantContainers[0];
			Raids.Standard.setFlag(container, this.getID(), lair);
			Raids.Standard.setFlag(format("%sTime", container), ::World.getTime().Days, lair);
			Raids.Standard.setFlag(format("%sDuration", container), this.getDiscoveryDuration(), lair);
			if (!isValid) isValid = true;
		}

		if (!isValid) return false;
		::Sound.play("sounds/cloth_01.wav", ::Const.Sound.Volume.Inventory);
		return true;
	}

	function getDiscoveryDuration()
	{
		return this.m.DiscoveryDays;
	}

	function getDiscoveryText()
	{
		return format("This edict takes effect in %s days.", Raids.Standard.colourWrap(this.getDiscoveryDuration(), "PositiveValue"));
	}

	function getEffectText()
	{
		return this.m.EffectText;
	}

	function getInstructionText()
	{
		return this.m.InstructionText;
	}

	function getPersistenceText()
	{
		local descriptor = Raids.Standard.colourWrap(this.isCycled() ? "temporary" : "permanent", "NegativeValue");
		return format("This edict's effects are %s.", descriptor);
	}

	function getScalingModality()
	{
		return this.m.ScalingModality;
	}

	function getScalingText()
	{
		local scaling = this.m.ScalingModality, modalities = this.m.ScalingModalities;
		if (scaling == modalities.Static) return format("This edict's effects are %s.", Raids.Standard.colourWrap("static", "PositiveValue"));
		return format("This edict's effects scale with lair %s.", Raids.Standard.colourWrap(scaling == modalities.Agitation ? "Agitation" : "resources", "NegativeValue"));
	}

	function getTooltip()
	{
		local tooltipArray =
		[
			{id = 1, type = "title", text = this.getName()},
			{id = 2, type = "description", text = this.getDescription()},
			{id = 66, type = "text", text = this.getValueString()},
			{id = 3, type = "image", image = this.getIcon()},
			{id = 6, type = "text", icon = "ui/icons/special.png", text = this.getEffectText()},
			{id = 6, type = "text", icon = "ui/icons/scroll_01.png", text = this.getPersistenceText()},
			{id = 6, type = "text", icon = "ui/icons/action_points.png", text = this.getDiscoveryText()},
			{id = 6, type = "text", icon = "ui/icons/level.png", text = this.getScalingText()},
			{id = 65, type = "text", text = this.getInstructionText()}
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

		local Edicts = Raids.Edicts, edictName = Edicts.getEdictName(this.getID()),
		lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (!Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (Edicts.findEdict(edictName, _lair) != false)
			{
				return false;
			}

			if (Edicts.findEdictInHistory(edictName, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

	function isCycled()
	{
		return Raids.Edicts.CycledEdicts.find(Raids.Edicts.getEdictName(this.getID())) != null;
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