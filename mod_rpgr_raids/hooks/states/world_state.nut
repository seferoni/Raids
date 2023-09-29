::mods_hookExactClass("states/world_state", function( object )
{
    /*local parentName = object.SuperName;

    local oCF_nullCheck = "onCombatFinished" in object ? object.onCombatFinished : null;
    object.onCombatFinished = function()
    {
        local vanilla_onCombatFinished = oCF_nullCheck == null ? this[parentName].onCombatFinished() : oCF_nullCheck();
        local worldFlags = ::World.Statistics.getFlags();

        if (!worldFlags.get("LastFoeWasParty"))
        {
            ::RPGR_Raids.log("Last combat encounter was not against a party, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        if (worldFlags.get("LastCombatWasArena"))
        {
            ::RPGR_Raids.log("Last combat encounter was flagged as an arena battle, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        if (typeof worldFlags.get("LastCombatFaction") != "integer")
        {
            ::RPGR_Raids.log("Last encountered faction flag was a non-integer data type container, aborting lair agitation procedure.", true);
            return vanilla_onCombatFinished;
        }

        if (worldFlags.get("LastCombatFaction") > ::World.FactionManager.m.Factions.len() - 1)
        {
            ::RPGR_Raids.log("Retrieved faction index was out of bounds for master factions array length, aborting lair agitation procedure.", true);
            return vanilla_onCombatFinished;
        }

        local faction = ::World.FactionManager.getFaction(worldFlags.get("LastCombatFaction"));

        if (!::RPGR_Raids.isFactionViable(faction))
        {
            ::RPGR_Raids.log("findLairCandidates took on a non-viable faction as an argument, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        if (::World.getPlayerRoster().getSize() == 0 || !::World.Assets.getOrigin().onCombatFinished())
        {
            return vanilla_onCombatFinished;
        }

        if (worldFlags.getAsInt("LastCombatResult") != 1)
        {
            ::RPGR_Raids.log("Last combat result was flagged as defeat, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationIncrementChance").getValue())
        {
            ::RPGR_Raids.log("Dice roll result exceeds threshold for agitation increment chance, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        local lairs = ::RPGR_Raids.findLairCandidates(faction);

        if (lairs.len() == 0)
        {
            ::RPGR_Raids.log("findLairCandidates could not find any eligible lairs within proximity of the player.");
            return vanilla_onCombatFinished;
        }

        local iterations = worldFlags.get("LastFoeWasVanguardParty") == false ? 1 : 2;
        ::RPGR_Raids.agitateViableLairs(lairs, iterations);
        ::RPGR_Raids.updateCombatStatistics(false, false);
        return vanilla_onCombatFinished;
    }*/

    Raids.Standard.wrap(object, "onCombatFinished", function( _originalResult )
    {
        local worldFlags = ::World.Statistics.getFlags();

        if (!worldFlags.get("LastFoeWasParty"))
        {
            Raids.Standard.log("Last combat encounter was not against a party, aborting lair agitation procedure.");
            return;
        }

        if (worldFlags.get("LastCombatWasArena"))
        {
            Raids.Standard.log("Last combat encounter was flagged as an arena battle, aborting lair agitation procedure.");
            return;
        }

        if (typeof worldFlags.get("LastCombatFaction") != "integer")
        {
            Raids.Standard.log("Last encountered faction flag was a non-integer data type container, aborting lair agitation procedure.", true);
            return;
        }

        if (worldFlags.get("LastCombatFaction") > ::World.FactionManager.m.Factions.len() - 1)
        {
            Raids.Standard.log("Retrieved faction index was out of bounds for master factions array length, aborting lair agitation procedure.", true);
            return;
        }

        local faction = ::World.FactionManager.getFaction(worldFlags.get("LastCombatFaction"));

        if (!Raids.Lairs.isFactionViable(faction))
        {
            Raids.Standard.log("findLairCandidates took on a non-viable faction as an argument, aborting lair agitation procedure.");
            return;
        }

        if (::World.getPlayerRoster().getSize() == 0 || !::World.Assets.getOrigin().onCombatFinished())
        {
            return;
        }

        if (worldFlags.getAsInt("LastCombatResult") != 1)
        {
            Raids.Standard.log("Last combat result was flagged as defeat, aborting lair agitation procedure.");
            return;
        }

        if (::Math.rand(1, 100) > Raids.Standard.getSetting("AgitationIncrementChance"))
        {
            Raids.Standard.log("Dice roll result exceeds threshold for agitation increment chance, aborting lair agitation procedure.");
            return;
        }

        local lairs = Raids.Lairs.findLairCandidates(faction);

        if (lairs.len() == 0)
        {
            Raids.Standard.log("findLairCandidates could not find any eligible lairs within proximity of the player.");
            return;
        }

        local iterations = worldFlags.get("LastFoeWasVanguardParty") == false ? 1 : 2;
        Raids.Lairs.agitateViableLairs(lairs, iterations);
        Raids.Lairs.updateCombatStatistics(false, false);
    }, "overrideReturn");
});