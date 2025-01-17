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
		::Raids.Standard.setFlag("FlaggedForRemoval", true, this);
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
		local stackThresholds = ::Raids.Edicts.Stackables.getField("IconStackThresholds");

		foreach( thresholdDescriptor, thresholdTable in stackThresholds )
		{
			if (!::Raids.Standard.isWithinRange(currentStacks, thresholdTable.Range))
			{
				continue;
			}

			this.setIconWithSuffix(thresholdTable.IconSuffix);
			break;
		}
	}

	function recalculateValue()
	{
		local currentStacks = this.getCurrentStacks();
		this.m.Value = currentStacks * this.m.ValueNative;
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
		::Tooltip.reload();
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
	{
		return ::Raids.Standard.getFlag("FlaggedForRemoval", this);
	}

	function setDescription( _properName )
	{
		local key = format("%sDescription", this.formatName(_properName));
		this.m.Description = format("%s %s", this.m.DescriptionPrefix, ::Raids.Strings.Edicts[key]);
	}

	function setIconWithSuffix( _suffixString )
	{
		this.m.Icon = format("%s%s.png", this.m.IconNative, _suffixString);
	}

	function setName( _properName )
	{
		local key = format("%sName", this.formatName(_properName));
		this.m.Name = ::Raids.Strings.Edicts[key];
	}

	function setNativeIcon( _iconPath )
	{
		this.m.Icon = format("%s.png", _iconPath);
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