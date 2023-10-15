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
            Raids.Standard.log("Last combat result was flagged as defeat, aborting lair agitation procedure.");
            return;
        }

        if (::Math.rand(1, 100) > Raids.Standard.getSetting("AgitationIncrementChance"))
        {
            return;
        }

        local naiveLairs = Raids.Lairs.getCandidatesByFaction(faction);

        if (naiveLairs.len() == 0)
        {
            return;
        }

        local lairs = Raids.Lairs.filterActiveContractLocations(naiveLairs);

        if (lairs.len() == 0)
        {
            return;
        }

        foreach( lair in lairs )
        {
            Raids.Lairs.setAgitation(lair, Raids.Lairs.Procedures.Increment);
        } 
    });
});