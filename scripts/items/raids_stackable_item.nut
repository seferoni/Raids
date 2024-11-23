this.raids_stackable_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.raids_item.create();
	}

	function refreshIcon()
	{

	}

	function recalculateValue()
	{

	}

	function getStacks()
	{

	}

	function onAddedToStash( _stashID )
	{
		this.raids_item.onAddedToStash(_stashID);
	}

	function onUse( _actor, _item = null )
	{
		this.raids_item.onUse(_actor, _item);
	}

	function setStacks( _value )
	{

	}
});