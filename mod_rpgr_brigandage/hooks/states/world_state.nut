::mods_hookExactClass("states/world_state", function( object )
{
    local parentName = object.SuperName;

    local oCF_nullCheck = "onCombatFinished" in object ? object.onCombatFinished : null;
    object.onCombatFinished = function()
    {
        local vanilla_onCombatFinished = oCF_nullCheck == null ? this[parentName].onCombatFinished : oCF_nullCheck;
        local activeContract = ::World.Contracts.getActiveContract();

        if (::World.Statistics.getFlags().get("LastCombatWasArena"))
        {
            return vanilla_onCombatFinished();
        }

        if (::Math.rand(1, 100) > ::RPGR_Brigandage.Mod.ModSettings.getSetting("AgitationIncrementChance").getValue())
        {
            ::logInfo("Random number was larger than agitation increment chance.");
            return vanilla_onCombatFinished();
        }

        local factionCandidates = [];

        foreach( party in this.m.PartiesInCombat )
        {
            if (party.isAlive() && party.m.Troops.len() == 0 && !party.isLocation() && !party.isAlliedWithPlayer()) // TODO: consider the ramifications of this
            {
                factionCandidates.push(::World.FactionManager.getFaction(party.getFaction()));
            }
        }

        if (factionCandidates.len() == 0)
        {
            ::logInfo("Factions was found to be empty.");
        }

        // TODO: note that there can be multiple factions in a fight. Test behaviour for such cases before shipping

        local filteredFactions = factionCandidates.filter(function( factionIndex, faction )
        {
            return ::RPGR_Brigandage.isFactionViable(faction) && faction.getSettlements().len() != 0;
        });

        if (filteredFactions.len() == 0)
        {
            ::logInfo("Parties have no applicable faction, returning.");
            return vanilla_onCombatFinished();
        }

        ::logInfo("Proceeding to lair candidate selection.");

        local agitatedFaction = filteredFactions[::Math.rand(0, filteredFactions.len() - 1)];
        local lairs = agitatedFaction.getSettlements().filter(function( locationIndex, location )
        {
            return location.getLocationType() == ::Const.World.LocationType.Lair && ::World.State.getPlayer().getTile().getDistanceTo(location.getTile()) <= ::RPGR_Brigandage.CampaignModifiers.MaximumDistanceToAgitate;
        });

        if (lairs.len() == 0)
        {
            ::logInfo("Could not find any lairs within proximity.");
            return vanilla_onCombatFinished();
        }

        foreach( lair in lairs )
        {
            if (lair.getFlags().get("Agitation") <= ::RPGR_Brigandage.AgitationDescriptors.Desperate && (activeContract == null || activeContract.m.Destination != this))
            {
                ::RPGR_Brigandage.setLairAgitation(lair, ::RPGR_Brigandage.Procedures.Increment);
                ::logInfo("Found lair candidate, incremented agitation.");
                break;
            }
        }

        return vanilla_onCombatFinished();
    }
});