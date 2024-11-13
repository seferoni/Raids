::Raids.Patcher.hook("scripts/states/world_state", function( p )
{
	::Raids.Patcher.wrap(p, "onCombatFinished", function()
	{
		if (!::Raids.Standard.getFlag("LastFoeWasParty", ::World.Statistics))
		{
			return;
		}

		if (::Raids.Standard.getFlag("LastCombatWasArena", ::World.Statistics))
		{
			return;
		}

		local factionIndex = ::Raids.Standard.getFlag("LastCombatFaction", ::World.Statistics);

		if (!(factionIndex in ::World.FactionManager.m.Factions))
		{
			::Raids.Standard.log("Retrieved faction index was out of bounds, aborting lair agitation procedure.", true);
			return;
		}

		local faction = ::World.FactionManager.getFaction(factionIndex);

		if (!::Raids.Lairs.isFactionViable(faction))
		{
			return;
		}

		if (::World.getPlayerRoster().getSize() == 0 || !::World.Assets.getOrigin().onCombatFinished() || ::Raids.Standard.getFlagAsInt("LastCombatResult", ::World.Statistics) != 1)
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
			::Raids.Lairs.setAgitation(lair, ::Raids.Lairs.Procedures.Increment);
		}
	});
});