this.raids_stackable_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.raids_item.create();
	}

	function assignStackableProperties()
	{
		local currentStacks = this.getStacks();

		if (currentStacks == false)
		{
			this.overrideStacks(1);
		}
	}

	function decrementStacks()
	{
		local currentStacks = this.getStacks();

		if (currentStacks - 1 <= 0)
		{
			this.queueForRemoval();
			return;
		}

		this.overrideStacks(currentStacks - 1);
	}

	function onStackUpdate()
	{
		this.refreshIcon();
		this.recalculateValue();
	}

	function refreshIcon()
	{
		// TODO:
	}

	function recalculateValue()
	{
		// TODO: getting the default value of m.Value might be a pickle. might also not be a pickle, since stackable properties can initialise on added to stash, ie, well after create()?
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

	function getProcedures()
	{
		return ::Raids.Database.getSubLevelField("Generic", "Procedures");
	}

	function getStacks()
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
		local currentStacks = this.getStacks();
		this.overrideStacks(currentStacks + 1);
	}

	function isQueuedForRemoval()
	{
		return ::Raids.Standard.getFlag("QueuedForRemoval", this);
	}

	function queueForRemoval()
	{
		::Raids.Standard.setFlag("QueuedForRemoval", this, true);
	}

	function removeIfQueued()
	{
		if (!this.isQueuedForRemoval())
		{
			return;
		}

		this.removeSelf();
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
			this.assignStackableProperties();
			return;
		}

		instances[0].setStacks(this.getProcedures().Increment);
		this.removeSelf();
	}
});