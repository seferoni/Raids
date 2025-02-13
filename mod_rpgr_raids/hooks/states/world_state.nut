::Raids.Patcher.hook("scripts/states/world_state", function( p )
{
	::Raids.Patcher.wrap(p, "onCombatFinished", function()
	{
		local statistics = ::Raids.Standard.getCombatStatistics();

		if (!statistics.LastFoeWasParty)
		{
			return;
		}

		if (statistics.LastCombatWasArena)
		{
			return;
		}

		if (statistics.LastCombatWasDefeat || ::World.getPlayerRoster().getSize() == 0 || !::World.Assets.getOrigin().onCombatFinished())
		{
			return;
		}

		if (!(statistics.LastCombatFaction in ::World.FactionManager.m.Factions))
		{
			::Raids.Standard.log(format(::Raids.Strings.Debug.UndefinedFaction, statistics.LastCombatFaction), true);
			return;
		}

		local faction = ::World.FactionManager.getFaction(statistics.LastCombatFaction);

		if (!::Raids.Lairs.isFactionViable(faction))
		{
			return;
		}

		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("AgitationIncrementChance"))
		{
			return;
		}

		local lairs = ::Raids.Lairs.getCandidatesByFaction(faction);

		if (lairs.len() == 0)
		{
			return;
		}

		foreach( lair in lairs )
		{
			::Raids.Lairs.setAgitation(lair, ::Raids.Standard.getProcedures().Increment);
		}
	});
});