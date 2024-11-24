this.raids_edict_item <- ::inherit("scripts/items/raids_stackable_item",
{	// TODO: all edicts require a NameAbbreviated field
	m = {},
	function create()
	{
		this.raids_stackable_item.create();
		this.assignEdictProperties();
	}

	function assignGenericProperties()
	{
		this.raids_stackable_item.assignGenericProperties();
		this.m.Icon = "special/raids_edict_item.png"; // TODO: if this is to inherit from raids_stackable_item, this needs to be functionalised
	}

	function assignEdictProperties()
	{
		this.m.DiscoveryDays <- 1;
		this.m.ScalingModality <- this.getScalingModalities().Static;
		this.m.ShowWarning <- false;
		this.m.AbbreviatedName <- "";
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
	{	// TODO: need a string handler to formalise this sorta logic.
		local colourWrap = @(_string) ::Raids.Standard.colourWrap(_string, ::Raids.Standard.Colour.Red);
		local getFragment = @(_fragmentIndex) ::Raids.Strings.Edicts[format("EdictWarningFragment%s", _fragmentIndex)];
		local fragmentA = format(getFragment("A"), colourWrap(getFragment("B")));
		local fragmentB =  format(getFragment("C"), colourWrap(getFragment("D")));
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			format("%s %s", fragmentA, fragmentB)
		);
	}

	function executeEdictProcedure( _lairs )
	{	// TODO: this should not return anything.
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
		return format(::Raids.Strings.Edicts.EdictDiscoveryText, discoveryText, ::Raids.Strings.Generic[discoveryDuration > 1 ? "Days" : "Day"]);
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
		local colourWrap = @(_text, _colour) ::Raids.Standard.colourWrap(_text, ::Raids.Standard.Colour[_colour]);
		local modalities = this.getScalingModalities();

		if (this.m.ScalingModality == modalities.Static)
		{
			return format(::Raids.Strings.Edicts.EdictScalingTextStatic, colourWrap(::Raids.Strings.Generic.Static, "Green"));
		}

		return format(::Raids.Strings.Edicts.EdictScalingText, colourWrap(::Raids.Strings.Generic[this.m.ScalingModality == modalities.Agitation ? "Agitation" : "resources"], "Red"));
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

		local edictName = ::Raids.Edicts.getSugaredID(this.getID()); // TODO: again with the edict name?
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
		::Raids.Standard.setFlag(_container, this.getID(), _lair); // TODO: it may be more useful to assign this to the sugared name, instead. have greater access to associated fields that way.
		::Raids.Standard.setFlag(format("%sTime", _container), ::World.getTime().Days, _lair);
		::Raids.Standard.setFlag(format("%sDuration", _container), this.m.DiscoveryDays, _lair);
	}

	function isCycled()
	{
		return ::Raids.Edicts.getField("CycledEdicts").find(this.getID()) != null;
	}

	function setEffectTextByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
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
		this.m.AbbreviatedName = ::Raids.Strings.Edicts[key].AbbreviatedName;
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

		return this.executeEdictProcedure(lairs); // TODO: this is a pickle to parse and make cohere with our removeIfQueued method structure
		// could potentially do a try catch? might not be a valid/legal use
	}
});