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
        local filteredParties = this.m.Parties.InCombat.filter(function( index, party )
        {
            if (!party.isAlive())
            {
                ::RPGR_Raids.logWrapper(party.getName() + " is not flagged as alive.");
            }

            return party.getTroops().len() == 0 && !party.isLocation() && party.isAlive();
        });

        foreach( party in filteredParties )
        {
            /*if (party.getFaction() > ::World.FactionManager.getFactions().len()) // this doesn't make sense at first glance
            {
                continue;
            }

            if (::World.FactionManager.getFactions().find(party.getFaction()) == null)
            {
                continue;
            }*/

            factionCandidates.push(::World.FactionManager.getFaction(party.getFaction()));
        }

        if (factionCandidates.len() == 0)
        {
            ::RPGR_Raids.logWrapper("onCombatFinished found no eligible parties.");
            return vanilla_onCombatFinished();
        }

        local filteredFactions = factionCandidates.filter(function( factionIndex, faction )
        {
            return ::RPGR_Raids.isFactionViable(faction) && faction.getSettlements().len() != 0;
        });

        if (filteredFactions.len() == 0)
        {
            ::RPGR_Raids.logWrapper("onCombatFinished found no eligible factions.");
            return vanilla_onCombatFinished();
        }

        ::RPGR_Raids.logWrapper("Proceeding to lair candidate selection.");

        local agitatedFaction = filteredFactions[::Math.rand(0, filteredFactions.len() - 1)]; // TODO: consider functionalising this
        local lairs = agitatedFaction.getSettlements().filter(function( locationIndex, location )
        {
            return ::RPGR_Raids.isLocationEligible(location.getLocationType()) && ::RPGR_Raids.isPlayerInProximityTo(location.getTile());
        });

        if (lairs.len() == 0)
        {
            ::RPGR_Raids.logWrapper("Could not find any lairs within proximity.");
            return vanilla_onCombatFinished();
        }

        foreach( lair in lairs )
        {
            if (!::RPGR_Raids.isActiveContractLocation(lair))
            {
                ::RPGR_Raids.setLairAgitation(lair, ::RPGR_Raids.Procedures.Increment);
                ::RPGR_Raids.logWrapper("Found lair candidate.");
            }
        }

        return vanilla_onCombatFinished();
    }
});