this.raids_stackable_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.raids_item.create();
		// TODO: initialise stack functionality
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

	function refreshIcon()
	{
		// TODO:
	}

	function recalculateValue()
	{

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
	}

	function onUse( _actor, _item = null )
	{
		this.raids_item.onUse(_actor, _item);
	}

	function incrementStacks()
	{
		local currentStacks = this.getStacks();
		this.setStacks(currentStacks + 1);
	}

	function setStacks( _procedure )
	{
		local procedures = this.getProcedures();

		switch (_procedure)
		{
			case (procedures.Increment): this.incrementStacks(); break;
			case (procedures.Decrement): this.decrementStacks(); break;
		}

		this.refreshIcon();
		this.recalculateValue();
	}
});