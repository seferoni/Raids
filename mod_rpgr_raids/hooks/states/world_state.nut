::mods_hookExactClass("states/world_state", function( object )
{
    local parentName = object.SuperName;
    
    local oCF_nullCheck = "onCombatFinished" in object ? object.onCombatFinished : null;
    object.onCombatFinished = function()
    {
        local vanilla_onCombatFinished = oCF_nullCheck == null ? this[parentName].onCombatFinished() : oCF_nullCheck();
        local worldFlags = ::World.Statistics.getFlags();

        if (worldFlags.get("LastCombatWasArena") || worldFlags.get("LastCombatFaction") == false)
        {
            return vanilla_onCombatFinished;
        }

        if (::World.getPlayerRoster().getSize() == 0 || !::World.Assets.getOrigin().onCombatFinished())
        {
            return vanilla_onCombatFinished;
        }

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationIncrementChance").getValue())
        {
            return vanilla_onCombatFinished;
        }

        local faction = ::World.FactionManager.getFaction(worldFlags.get("LastCombatFaction"));

        if (faction == null)
        {
            return vanilla_onCombatFinished;
        }

        if (!::RPGR_Raids.isFactionViable(faction))
        {
            return vanilla_onCombatFinished;
        }

        local lairs = ::RPGR_Raids.findLairCandidates(faction);

        if (lairs == null)
        {
            return vanilla_onCombatFinished;
        }

        ::RPGR_Raids.agitateViableLairs(lairs);
        return vanilla_onCombatFinished;
    }
});