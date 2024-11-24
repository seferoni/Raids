this.raids_stackable_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.raids_item.create();
		this.assignStackableProperties();
	}

	function assignStackableProperties()
	{
		local currentStacks = this.getStacks();

		if (currentStacks == false)
		{
			this.setStacks(this.getProcedures().Override, 1);
		}
	}

	function decrementStacks()
	{
		local currentStacks = this.getStacks();

		if (currentStacks - 1 <= 0)
		{
			this.removeSelf();
			return;
		}

		this.setStacks(currentStacks - 1);
	}

	function onStackUpdate()
	{	// TODO: may need to move this to whatever handles stack updates
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
	}

	function overrideStacks( _newValue )
	{
		::Raids.Standard.setFlag("Stacks", _newValue, this);
	}

	function incrementStacks()
	{
		local currentStacks = this.getStacks();
		this.setStacks(currentStacks + 1);
	}

	function setStacks( _procedure, _newValue = null )
	{
		local procedures = this.getProcedures();

		switch (_procedure)
		{
			case (procedures.Increment): this.incrementStacks(); break;
			case (procedures.Decrement): this.decrementStacks(); break;
			case (procedures.Override): this.overrideStacks(_newValue); break;
		}

		this.refreshIcon();
		this.recalculateValue();
	}

	function updateStacks()
	{	// TODO: unfinished. shouldn't this responsibility be delegated to another handler? couupling it to the item itself seems short-sighted
		local instances = this.getItemInstancesInStash();
		local tally = instances.len();

		if (tally <= 1)
		{
			return;
		}

		local proxy = instances.pop();


		this.onStackUpdate();
	}
});