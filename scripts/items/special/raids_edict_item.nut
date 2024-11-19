this.raids_edict_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.raids_item.create();
		this.assignEdictProperties();
	}

	function assignGenericProperties()
	{
		this.raids_item.assignGenericProperties();
		this.m.Icon = "special/raids_edict_item.png";
	}

	function assignEdictProperties()
	{
		this.m.DiscoveryDays <- 1;
		this.m.ScalingModality <- this.getScalingModalities().Static;
		this.m.ShowWarning <- false;
		this.m.EffectText <- "";
	}

	function assignPropertiesByName( _properName )
	{
		this.setIDByName(_properName);
		this.setDescription(_properName);
		this.setName(_properName);
		this.setEffectTextByName(_properName);
	}

	function assignSoundProperties()
	{
		this.raids_item.assignSoundProperties();
		this.m.UseSound = "sounds/cloth_01.wav";
		this.m.InventorySound = "sounds/cloth_01.wav";
	}

	function createDiscoveryEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Time",
			this.getDiscoveryText()
		);
	}

	function createEffectEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Special",
			this.m.EffectText
		);
	}

	function createInstructionEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			null,
			::Raids.Strings.Edicts.EdictInstructionText
		);
	}

	function createPersistenceEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Persistence",
			this.getPersistenceText()
		);
	}

	function createScalingEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Scaling",
			this.getScalingText()
		);
	}

	function createWarningEntry()
	{
		local colourWrap = @(_string) ::Raids.Standard.colourWrap(_string, ::Raids.Standard.Colour.Red);
		local fragmentA = format(::Raids.Strings.Edicts.EdictWarningFragmentA, colourWrap(::Raids.Strings.Edicts.EdictWarningFragmentB));
		local fragmentB =  format(::Raids.Strings.Edicts.EdictWarningFragmentC, colourWrap(::Raids.Strings.Edicts.EdictWarningFragmentD));
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			format("%s %s", fragmentA, fragmentB)
		);
	}

	function executeEdictProcedure( _lairs )
	{
		local isValid = false;

		foreach( lair in _lairs )
		{
			local vacantContainers = clone ::Raids.Edicts.getField("Containers");
			::Raids.Standard.removeFromArray(::Raids.Edicts.getOccupiedContainers(lair), vacantContainers);

			if (vacantContainers.len() == 0)
			{
				continue;
			}

			this.initialiseContainer(vacantContainers[0], lair);
			isValid = true;
		}

		if (isValid == false)
		{
			return false;
		}

		this.playUseSound();
		return true;
	}

	function getDiscoveryText()
	{
		local discoveryText = ::Raids.Standard.colourWrap(this.m.DiscoveryDays, ::Raids.Standard.Colour.Green);
		return format("This Edict takes effect in %s %s.", discoveryText, discoveryDuration > 1 ? "days" : "day");
	}

	function getPersistenceText()
	{
		local descriptor = ::Raids.Standard.colourWrap(::Raids.Strings.Generic[this.isCycled() ? "Temporary" : "Permanent"], ::Raids.Standard.Colour.Red);
		return format(::Raids.Strings.Edicts.EdictPersistenceText, descriptor);
	}

	function getScalingModalities()
	{
		return ::Raids.Edicts.getField("ScalingModalities");
	}

	function getScalingText()
	{
		local modalities = this.getScalingModalities();

		if (this.m.ScalingModality == modalities.Static)
		{
			return format(::Raids.Strings.Edicts.EdictScalingTextStatic, ::Raids.Standard.colourWrap("static", ::Raids.Standard.Colour.Green));
		}

		return format(::Raids.Strings.Edicts.EdictScalingText, ::Raids.Standard.colourWrap(this.m.ScalingModality == modalities.Agitation ? "Agitation" : "resources", ::Raids.Standard.Colour.Red));
	}

	function getTooltip()
	{
		local tooltipArray = this.raids_item.getTooltip();
		local push = @(_entry) ::Raids.Standard.push(_entry, tooltipArray);

		push(this.createEffectEntry());
		push(this.createPersistenceEntry());
		push(this.createDiscoveryEntry());
		push(this.createScalingEntry());

		if (this.m.ShowWarning)
		{
			push(this.createWarningEntry());
			this.setWarningState(false);
		}

		push(this.createInstructionEntry());
		return tooltipArray;
	}

	function getViableLairs()
	{
		local naiveLairs = ::Raids.Lairs.getCandidatesWithin(::World.State.getPlayer().getTile());

		if (naiveLairs.len() == 0)
		{
			return naiveLairs;
		}

		local edictName = ::Raids.Edicts.getEdictName(this.getID()); // TODO: again with the edict name?
		local lairs = naiveLairs.filter(function( _index, _lair )
		{
			if (!::Raids.Edicts.isLairViable(_lair))
			{
				return false;
			}

			if (::Raids.Edicts.getOccupiedContainers(_lair).len() == ::Raids.Edicts.getField("Containers").len())
			{
				return false;
			}

			if (::Raids.Edicts.findEdict(edictName, _lair) != false)
			{
				return false;
			}

			if (::Raids.Edicts.findEdictInHistory(edictName, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

	function initialiseContainer( _container, _lair )
	{
		::Raids.Standard.setFlag(_container, this.getID(), _lair);
		::Raids.Standard.setFlag(format("%sTime", _container), ::World.getTime().Days, _lair);
		::Raids.Standard.setFlag(format("%sDuration", _container), this.m.DiscoveryDays, _lair);
	}

	function isCycled()
	{
		local edictName = ::Raids.Edicts.getEdictName(this.getID()); // TODO: what precisely is 'edict name'? is it an internally tracked name?
		return ::Raids.Edicts.getField("CycledEdicts").find(edictName) != null;
	}

	function setEffectTextByName( _properName )
	{
		// TODO:
	}

	function setIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("special.raids_%s_item", formattedName.tolower());
	}

	function setName( _properName )
	{
		local key = this.formatName(_properName);
		this.m.Name = ::Raids.Strings.Edicts[format("%sName", key)];
	}

	function setWarningState( _bool )
	{
		this.m.ShowWarning = _bool;
	}

	function onUse( _actor, _item = null )
	{	// TODO: may want to have handle valid and invalid use methods here
		local lairs = this.getViableLairs();

		if (lairs.len() == 0)
		{
			this.setWarningState(true);
			this.playWarningSound();
			::Tooltip.reload();
			return false;
		}

		return this.executeEdictProcedure(lairs);
	}
});