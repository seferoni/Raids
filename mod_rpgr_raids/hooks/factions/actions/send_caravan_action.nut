::Raids.Patcher.hook("scripts/factions/actions/send_caravan_action", function( p )
{
	::Raids.Patcher.wrap(p, "onExecute", function( _faction )
	{
		local grossEntities = ::World.getAllEntitiesAtPos(this.m.Start.getPos(), 1.0);
		local caravan = null;

		foreach( entity in grossEntities )
		{
			if (::Raids.Caravans.isPartyViable(entity) && !::Raids.Caravans.isPartyInitialised(entity))
			{
				caravan = entity;
			}
		}

		if (caravan == null)
		{
			::Raids.Standard.log(format(::Raids.Strings.Debug.NoCaravanFound, this.m.Start.getName()), true);
			return;
		}

		::Raids.Caravans.initialiseCaravanParameters(caravan, this.m.Start);
	});
});