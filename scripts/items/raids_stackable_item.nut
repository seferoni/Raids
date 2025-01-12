this.raids_stackable_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.raids_item.create();
		this.assignStackableProperties();
	}

	function assignGenericProperties()
	{
		this.raids_item.assignGenericProperties();
		this.m.IconNative <- "";
		this.m.ValueNative <- "";
	}

	function assignPropertiesByName( _properName )
	{
		this.setIDByName(_properName);
		this.setDescription(_properName);
		this.setName(_properName);
	}

	function assignStackableProperties()
	{
		local currentStacks = this.getCurrentStacks();

		if (currentStacks == false)
		{
			this.overrideStacks(1);
		}
		
		this.onStackUpdate();
	}

	function createStackEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Stacks",
			format(::Raids.Strings.Generic.StacksCount, ::Raids.Standard.colourWrap(this.getCurrentStacks(), ::Raids.Standard.Colour.Green))
		);
	}

	function decrementStacks()
	{
		local currentStacks = this.getCurrentStacks();

		if (currentStacks - 1 <= 0)
		{
			this.flagForRemoval();
			return;
		}

		this.overrideStacks(currentStacks - 1);
	}

	function flagForRemoval()
	{
		::Raids.Standard.setFlag("FlaggedForRemoval", this, true);
	}

	function getTooltip()
	{
		local tooltipArray = this.raids_item.getTooltip();
		local push = @(_entry) ::Raids.Standard.push(_entry, tooltipArray);

		push(this.createStackEntry());
		return tooltipArray;
	}

	function refreshIcon()
	{
		local currentStacks = this.getCurrentStacks();
		local stackThresholds = this.getField("IconStackThresholds");

		foreach( thresholdDescriptor, thresholdTable in stackThresholds )
		{
			::logInfo("examining " + thresholdDescriptor);

			if (!::Raids.Standard.isWithinRange(currentStacks, thresholdTable.Range))
			{
				continue;
			}

			::logInfo("for current stacks " + currentStacks + ", setting " + thresholdDescriptor)
			this.setIconWithSuffix(thresholdTable.IconSuffix);
			break;
		}
	}

	function recalculateValue()
	{
		local currentStacks = this.getCurrentStacks();
		this.m.Value = currentStacks * this.m.ValueNative;
	}

	function getField( _fieldName )
	{
		return ::Raids.Database.getField("Stackables", _fieldName);
	}

	function getCurrentStacks()
	{
		return ::Raids.Standard.getFlag("Stacks", this);
	}

	function onAddedToStash( _stashID )
	{
		this.raids_item.onAddedToStash(_stashID);
		::Raids.Edicts.Stackables.updateStash(this.getID());
	}

	function onStackUpdate()
	{
		this.refreshIcon();
		this.recalculateValue();
	}

	function overrideStacks( _newValue )
	{
		::Raids.Standard.setFlag("Stacks", _newValue, this);
	}

	function incrementStacks()
	{
		local currentStacks = this.getCurrentStacks();
		this.overrideStacks(currentStacks + 1);
	}

	function isFlaggedForRemoval()
	{	// TODO: this needn't exist as a flagged property.
		return ::Raids.Standard.getFlag("FlaggedForRemoval", this);
	}

	function setIconWithSuffix( _suffixString )
	{
		this.m.Icon = format("%s%s%s", this.m.IconNative, _suffixString, ".png");
	}

	function setNativeIcon( _iconPath )
	{
		this.m.Icon = format("%s%s", _iconPath, ".png"); // TODO: there needs to be a set icon method that automatically appends the ".png" filetype
		this.m.IconNative = _iconPath;
	}

	function setNativeValue( _value )
	{
		this.m.Value = _value;
		this.m.ValueNative = _value;
	}

	function setStacks( _procedure )
	{
		local procedures = ::Raids.Standard.getProcedures();

		switch (_procedure)
		{
			case (procedures.Increment): this.incrementStacks(); break;
			case (procedures.Decrement): this.decrementStacks(); break;
		}

		this.onStackUpdate();
	}
});