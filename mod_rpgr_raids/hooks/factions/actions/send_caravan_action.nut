::Raids.Patcher.hook("scripts/factions/actions/send_caravan_action", function( p )
{
	::Raids.Patcher.wrap(p, "onExecute", function( _faction )
	{
		local caravan = ::Raids.Caravans.locateCaravanOnAction(this.m.Start);

		if (caravan == null)
		{
			::Raids.Standard.log(format(::Raids.Strings.Debug.NoCaravanFound, this.m.Start.getName()), true);
			return;
		}

		::Raids.Caravans.initialiseCaravanParameters(caravan, this.m.Start);
	});
});