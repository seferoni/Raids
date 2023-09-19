::mods_hookBaseClass("factions/faction", function( object )
{
    local parentName = object.SuperName;

    local sE_nullCheck = "spawnEntity" in object ? object.spawnEntity : null;
    object.spawnEntity <- function( _tile, _name, _uniqueName, _template, _resources )
    {
        local party = sE_nullCheck == null ? this[parentName].spawnEntity(_tile, _name, _uniqueName, _template, _resources) : sE_nullCheck(_tile, _name, _uniqueName, _template, _resources);

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("RoamerScaleChance").getValue())
        {
            return party;
        }

        if (!::RPGR_Raids.isFactionViable(this))
        {
            return party;
        }

        if (_template == null)
        {
            return party;
        }

        local lairs = ::RPGR_Raids.findLairCandidatesAtPosition(party.getPos(), 1.0);

        if (lairs.len() == 0)
        {
            ::RPGR_Raids.logWrapper(format("No eligible lair in proximity of spawned party %s.", _name));
            return party;
        }

        local lair = lairs[0];

        if (::RPGR_Raids.Mod.ModSettings.getSetting("RoamerScaleAgitationRequirement").getValue() && lair.getFlags().get("Agitation") == ::RPGR_Raids.AgitationDescriptors.Relaxed)
        {
            return party;
        }

        if (::RPGR_Raids.isActiveContractLocation(lair))
        {
            return party;
        }

        local lairResources = lair.getResources();

        if (lairResources - _resources <= ::RPGR_Raids.CampaignModifiers.AssignmentResourceThreshold)
        {
            ::RPGR_Raids.logWrapper(format("Lair resource count for %s with %g resources is insufficient compared to the initial value of %g.", lair.getName(), lairResources, _resources));
            return party;
        }

        local baseResources = lair.getFlags().get("BaseResources");
        //local baseResourceModifier = 1.0 + (-0.0014 * lair.getFlags().get("BaseResources"));
        local baseResourceModifier = baseResources >= 200 ? (baseResources <= 350 ? -0.005 * baseResources + 2.0 : 0.25) : 1.0;
        local resourceDifference = baseResourceModifier * (::RPGR_Raids.Mod.ModSettings.getSetting("RoamerResourceModifier").getValue() / 100.0) * (lairResources - _resources);
        ::RPGR_Raids.logWrapper(format("%s with troop count %i is eligible for reinforcement.", _name, party.getTroops().len()));
        local isReinforced = ::RPGR_Raids.assignTroops(party, _template, resourceDifference);

        if (!isReinforced)
        {
            ::RPGR_Raids.logWrapper("Could not find a suitable party template for roamer reinforcement within alloted execution time, aborting procedure.");
        }

        ::RPGR_Raids.logWrapper(format("%s with new troop count %i has been reinforced with resource count %g.", _name, party.getTroops().len(), resourceDifference));

        if ((resourceDifference / _resources) * 100 >= ::RPGR_Raids.CampaignModifiers.AssignmentVanguardThresholdPercentage)
        {
            ::RPGR_Raids.initialiseVanguardParameters(party);
        }

        return party;
    }
});