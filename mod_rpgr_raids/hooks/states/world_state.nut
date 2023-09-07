::mods_hookExactClass("states/world_state", function( object )
{
    local parentName = object.SuperName;

    local oCF_nullCheck = "onCombatFinished" in object ? object.onCombatFinished : null;
    object.onCombatFinished = function()
    {
        local vanilla_onCombatFinished = oCF_nullCheck == null ? this[parentName].onCombatFinished() : oCF_nullCheck();
        local worldFlags = ::World.Statistics.getFlags();

        if (worldFlags.get("LastCombatWasArena"))
        {
            ::RPGR_Raids.logWrapper("Last combat encounter was flagged as an arena battle, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        if (worldFlags.get("LastCombatFaction") == false)
        {
            ::RPGR_Raids.logWrapper("Last encountered faction flag not initialised, aborting lair agitation procedure.", true);
            return vanilla_onCombatFinished;
        }

        local faction = ::World.FactionManager.getFaction(worldFlags.get("LastCombatFaction"));

        if (faction == null) // TODO: check if redundant
        {
            ::RPGR_Raids.logWrapper("Could not identify enemy faction, aborting lair agitation procedure.", true);
            return vanilla_onCombatFinished;
        }

        if (!::RPGR_Raids.isFactionViable(faction))
        {
            ::RPGR_Raids.logWrapper("findLairCandidates took on a non-viable faction as an argument, aborting procedure.");
            return vanilla_onCombatFinished;
        }

        if (::World.getPlayerRoster().getSize() == 0 || !::World.Assets.getOrigin().onCombatFinished())
        {
            return vanilla_onCombatFinished;
        }

        if (worldFlags.getAsInt("LastCombatResult") != 1)
        {
            ::RPGR_Raids.logWrapper("Last combat result was flagged as defeat, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationIncrementChance").getValue())
        {
            ::RPGR_Raids.logWrapper("Dice roll result exceeds threshold for agitation increment chance, aborting lair agitation procedure.");
            return vanilla_onCombatFinished;
        }

        local lairs = ::RPGR_Raids.findLairCandidates(faction);

        if (lairs == null)
        {
            return vanilla_onCombatFinished;
        }

        local iterations = worldFlags.get("LastCombatVanguardParty") == false ? 1 : 2;
        ::RPGR_Raids.agitateViableLairs(lairs, iterations);
        return vanilla_onCombatFinished;
    }
});