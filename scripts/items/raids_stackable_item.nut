this.raids_stackable_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.rids_item.create();
		this.assignStackableProperties();
	}

	function assignGenericProperties()
	{
		this.raids_item.assignGenericProperties();
		this.m.IconNative <- "";
		this.m.ValueNative <- "";
	}

	function assignStackableProperties()
	{
		local currentStacks = this.getCurrentStacks();

		if (currentStacks == false)
		{
			this.overrideStacks(1);
		}
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

	function onStackUpdate()
	{
		this.refreshIcon();
		this.recalculateValue();
	}

	function refreshIcon()
	{
		local currentStacks = this.getCurrentStacks();
		local stackThresholds = this.getIconStackThresholds();

		foreach( thresholdDescriptor, thresholdTable in stackThresholds )
		{
			if ("MaximumStacks" in thresholdTable && thresholdTable.MaximumStacks < currentStacks)
			{
				continue;
			}

			this.setIconWithSuffix(threshold.IconSuffix);
			break;
		}
	}

	function recalculateValue()
	{
		local currentStacks = this.getCurrentStacks();
		this.m.Value = currentStacks * this.m.ValueNative;
	}

	function getItemInstancesInStash()
	{
		local instances = [];
		local stash = ::World.Assets.getStash().filter(@(_index, _item) _item != null);

		foreach( item in stash )
		{
			if (item.getID() != this.getID())
			{
				continue;
			}

			instances.push(item);
		}

		return instances;
	}

	function getIconStackThresholds()
	{
		return ::Raids.Database.getSubLevelField("Stackables", "IconStackThresholds");
	}

	function getProcedures()
	{
		return ::Raids.Database.getSubLevelField("Generic", "Procedures");
	}

	function getCurrentStacks()
	{
		return ::Raids.Standard.getFlag("Stacks", this);
	}

	function onAddedToStash( _stashID )
	{
		this.raids_item.onAddedToStash(_stashID);
		this.updateStacks();
	}

	function onUse( _actor, _item = null )
	{
		this.raids_item.onUse(_actor, _item);
		this.setStacks(this.getProcedures().Decrement);
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

	function removeIfFlagged()
	{
		if (!this.isFlaggedForRemoval())
		{
			return;
		}

		this.removeSelf();
	}

	function setIconWithSuffix( _suffixString )
	{
		this.m.Icon = format("%s%s", this.m.IconNative, _suffixString);
	}

	function setNativeIcon( _iconPath )
	{
		this.m.Icon = _iconPath;
		this.m.IconNative = _iconPath;
	}

	function setNativeValue( _value )
	{
		this.m.Value = _value;
		this.m.ValueNative = _value;
	}

	function setStacks( _procedure )
	{
		local procedures = this.getProcedures();

		switch (_procedure)
		{
			case (procedures.Increment): this.incrementStacks(); break;
			case (procedures.Decrement): this.decrementStacks(); break;
		}

		this.onStackUpdate();
	}

	function updateStacks()
	{
		local instances = this.getItemInstancesInStash();

		if (instances.len() == 0)
		{
			return;
		}

		instances[0].setStacks(this.getProcedures().Increment);
		this.removeSelf();
	}
});