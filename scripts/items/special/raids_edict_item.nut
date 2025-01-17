this.raids_edict_item <- ::inherit("scripts/items/raids_stackable_item",
{
	m = {},
	function create()
	{
		this.raids_stackable_item.create();
		this.assignEdictProperties();
	}

	function assignGenericProperties()
	{
		this.raids_stackable_item.assignGenericProperties();
		this.setNativeIcon("special/raids_edict_item");
	}

	function assignEdictProperties()
	{
		this.m.DiscoveryDays <- 1;
		this.m.ScalingModality <- this.getScalingModalities().Static;
		this.m.ShowWarning <- false;
		this.m.NameAbbreviated <- "";
		this.m.EffectText <- "";
	}

	function assignPropertiesByName( _properName )
	{
		this.raids_stackable_item.assignPropertiesByName(_properName);
		this.setEffectTextByName(_properName);
	}

	function assignSpecialProperties()
	{
		this.raids_stackable_item.assignSpecialProperties();
		this.m.DescriptionPrefix = ::Raids.Strings.Edicts.EdictDescriptionPrefix;
	}

	function assignSoundProperties()
	{
		this.raids_stackable_item.assignSoundProperties();
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
			::Raids.Strings.Edicts.EdictInstruction
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
		local compiledString = ::Raids.Strings.getFragmentsAsCompiledString("EdictWarningFragment", "Edicts");
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			compiledString
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

		if (!isValid)
		{
			return;
		}

		this.playUseSound();
		this.setStacks(::Raids.Standard.getProcedures().Decrement);
	}

	function getDiscoveryText()
	{
		local discoveryDays = ::Raids.Standard.colourWrap(this.m.DiscoveryDays, ::Raids.Standard.Colour.Green);
		return format(::Raids.Strings.Edicts.EdictDiscovery, discoveryDays, ::Raids.Strings.Generic[this.m.DiscoveryDays > 1 ? "Days" : "Day"]);
	}

	function getPersistenceText()
	{
		local descriptor = ::Raids.Standard.colourWrap(::Raids.Strings.Generic[this.isCycled() ? "Temporary" : "Permanent"], ::Raids.Standard.Colour.Red);
		return format(::Raids.Strings.Edicts.EdictPersistence, descriptor);
	}

	function getScalingModalities()
	{
		return ::Raids.Edicts.getField("ScalingModalities");
	}

	function getScalingText()
	{
		local colourWrap = @(_text, _colour) ::Raids.Standard.colourWrap(_text, ::Raids.Standard.Colour[_colour]);
		local modalities = this.getScalingModalities();

		if (this.m.ScalingModality == modalities.Static)
		{
			return format(::Raids.Strings.Edicts.EdictScalingStatic, colourWrap(::Raids.Strings.Generic.Static, "Green"));
		}

		return format(::Raids.Strings.Edicts.EdictScaling, colourWrap(::Raids.Strings.Generic[this.m.ScalingModality == modalities.Agitation ? "Agitation" : "Resources"], "Red"));
	}

	function getSugaredID()
	{
		return ::Raids.Edicts.getSugaredID(this.getID());
	}

	function getTooltip()
	{
		local tooltipArray = this.raids_stackable_item.getTooltip();
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

		local sugaredID = this.getSugaredID();
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

			if (::Raids.Edicts.findEdict(sugaredID, _lair) != false)
			{
				return false;
			}

			if (::Raids.Edicts.findEdictInHistory(sugaredID, _lair) != false)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

	function handleInvalidUse()
	{
		this.setWarningState(true);
		this.playWarningSound();
		::Tooltip.reload();
		return false;
	}

	function handleValidUse()
	{
		if (this.isFlaggedForRemoval())
		{
			return true;
		}

		return false;
	}

	function initialiseContainer( _container, _lair )
	{
		::Raids.Standard.setFlag(_container, this.getSugaredID(), _lair);
		::Raids.Standard.setFlag(format("%sTime", _container), ::World.getTime().Days, _lair);
		::Raids.Standard.setFlag(format("%sDuration", _container), this.m.DiscoveryDays, _lair);
	}

	function isCycled()
	{
		return ::Raids.Edicts.getField("CycledEdicts").find(this.getSugaredID()) != null;
	}

	function setDescription( _properName )
	{
		local key = this.formatName(_properName, "_");
		this.m.Description = format("%s %s", this.m.DescriptionPrefix, ::Raids.Strings.Edicts[key].Description);
	}

	function setEffectTextByName( _properName )
	{
		local key = this.formatName(_properName, "_");
		this.m.EffectText = ::Raids.Strings.Edicts[key].Effect;
	}

	function setIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("special.raids_edict_of_%s_item", formattedName.tolower());
	}

	function setName( _properName )
	{
		local key = this.formatName(_properName);
		this.m.Name = ::Raids.Strings.Edicts[key].Name;
		this.m.NameAbbreviated = ::Raids.Strings.Edicts[key].NameAbbreviated;
	}

	function setWarningState( _bool )
	{
		this.m.ShowWarning = _bool;
	}

	function onUse( _actor, _item = null )
	{
		this.raids_stackable_item.onUse(_actor, _item);
		local lairs = this.getViableLairs();

		if (lairs.len() == 0)
		{
			return this.handleInvalidUse();
		}

		this.executeEdictProcedure(lairs);
		this.refreshStash();
		return this.handleValidUse();
	}
});