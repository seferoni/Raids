::mods_hookExactClass("states/world_state", function( object )
{
    local parentName = object.SuperName;

    local oCF_nullCheck = "onCombatFinished" in object ? object.onCombatFinished : null;
    object.onCombatFinished = function()
    {
        local vanilla_onCombatFinished = oCF_nullCheck == null ? this[parentName].onCombatFinished : oCF_nullCheck;

        if (::World.Statistics.getFlags().get("LastCombatWasArena"))
        {
            return vanilla_onCombatFinished();
        }

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationIncrementChance").getValue())
        {
            return vanilla_onCombatFinished();
        }

        local factionCandidates = [];

        foreach( party in this.m.PartiesInCombat )
        {
            if (!party.isAlive())
            {
                ::logInfo(party.getName() + " is not alive!");
            }

            if (party.isAlive() && party.m.Troops.len() == 0 && !party.isLocation())
            {
                factionCandidates.push(::World.FactionManager.getFaction(party.getFaction()));
            }
        }

        if (factionCandidates.len() == 0)
        {
            ::logInfo("[Raids] onCombatFinished found no eligible parties.");
            return vanilla_onCombatFinished();
        }

        // TODO: note that there can be multiple factions in a fight. Test behaviour for such cases before shipping

        local filteredFactions = factionCandidates.filter(function( factionIndex, faction )
        {
            return ::RPGR_Raids.isFactionViable(faction) && faction.getSettlements().len() != 0;
        });

        if (filteredFactions.len() == 0)
        {
            ::logInfo("[Raids] onCombatFinished found no eligible factions.");
            return vanilla_onCombatFinished();
        }

        ::logInfo("Proceeding to lair candidate selection.");

        local agitatedFaction = filteredFactions[::Math.rand(0, filteredFactions.len() - 1)];
        local lairs = agitatedFaction.getSettlements().filter(function( locationIndex, location )
        {
            return ::RPGR_Raids.isLocationEligible(location.getLocationType()) && ::RPGR_Raids.isPlayerInProximityTo(location.getTile());
        });

        if (lairs.len() == 0)
        {
            ::logInfo("Could not find any lairs within proximity.");
            return vanilla_onCombatFinished();
        }

        foreach( lair in lairs )
        {
            if (!::RPGR_Raids.isActiveContractLocation(lair))
            {
                ::RPGR_Raids.setLairAgitation(lair, ::RPGR_Raids.Procedures.Increment);
                ::logInfo("Found lair candidate.");
            }
        }

        return vanilla_onCombatFinished();
    }
});