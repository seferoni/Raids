local Raids = ::RPGR_Raids;
::mods_hookExactClass("states/world_state", function( _object )
{
    Raids.Standard.wrap(_object, "onCombatFinished", function()
    {
        if (!Raids.Standard.getFlag("LastFoeWasParty", ::World.Statistics))
        {
            return;
        }

        if (Raids.Standard.getFlag("LastCombatWasArena", ::World.Statistics))
        {
            return;
        }

        local factionIndex = Raids.Standard.getFlag("LastCombatFaction", ::World.Statistics);

        if (!(factionIndex in ::World.FactionManager.m.Factions))
        {
            Raids.Standard.log("Retrieved faction index was out of bounds, aborting lair agitation procedure.", true);
            return;
        }

        local faction = ::World.FactionManager.getFaction(factionIndex);

        if (!Raids.Lairs.isFactionViable(faction))
        {
            return;
        }

        if (::World.getPlayerRoster().getSize() == 0 || !::World.Assets.getOrigin().onCombatFinished() || Raids.Standard.getFlagAsInt("LastCombatResult", ::World.Statistics) != 1)
        {
            ::logInfo(format("%i", ::World.Statistics.getFlags().getAsInt("LastCombatResult")));
            Raids.Standard.log("Last combat result was flagged as defeat, aborting lair agitation procedure.");
            return;
        }

        if (::Math.rand(1, 100) > Raids.Standard.getSetting("AgitationIncrementChance"))
        {
            Raids.Standard.log("Dice roll result exceeds threshold for agitation increment chance, aborting lair agitation procedure.");
            return;
        }

        local lairs = Raids.Lairs.getCandidatesByFaction(faction);

        if (lairs.len() == 0)
        {
            Raids.Standard.log("getCandidatesByFaction could not find any eligible lairs within proximity of the player.");
            return;
        }

        local iterations = Raids.Standard.getFlag("LastFoeWasProvokedParty", ::World.Statistics) == false ? 1 : 2;
        Raids.Lairs.agitateViableLairs(lairs, iterations);
        Raids.Lairs.updateCombatStatistics(false, false);
    });
});