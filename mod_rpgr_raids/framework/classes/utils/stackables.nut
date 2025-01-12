::Raids.Edicts.Stackables <-
{
	function getAllInstancesInStashByID( _itemID )
	{
		local instances = [];
		local stash = ::World.Assets.getStash().getItems().filter(@(_index, _item) _item != null);

		foreach( item in stash )
		{
			if (item.getID() != _itemID)
			{
				continue;
			}

			instances.push(item);
		}

		return instances;
	}

	function updateStash( _itemID )
	{
		local stash = ::World.Assets.getStash();
		local instances = this.getAllInstancesInStashByID(_itemID);

		if (instances.len() <= 1)
		{
			return;
		}

		local masterInstance = instances.pop();

		foreach( item in instances )
		{
			stash.remove(item);
		}

		masterInstance.setStacks(::Raids.Standard.getProcedures().Increment);
	}
};