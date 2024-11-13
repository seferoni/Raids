::Raids.Patcher.hook("scripts/factions/actions/send_undead_roamers_action", function( p )
{
	::Raids.Patcher.wrap(p, "onUpdate", function( _faction )
	{
		if (::World.getTime().Days >= 20)
		{
			return;
		}

		# The code that follows is taken more or less verbatim from the vanilla codebase, with only cosmetic alterations.
		local settlements = _faction.getSettlements();

		if (settlements.len() < 6)
		{
			return;
		}

		if (_faction.getUnits().len() >= 3)
		{
			return;
		}

		local isAllowed = false;

		foreach( settlement in _faction.getSettlements() )
		{
			if (settlement.getLastSpawnTime() + 300.0 > ::Time.getVirtualTimeF())
			{
				continue;
			}

			isAllowed = true;
			break;
		}

		if (!isAllowed)
		{
			return;
		}

		this.m.Score = 10;
		return ::Raids.Internal.TERMINATE;
	}, "overrideMethod");
});