local Raids = ::RPGR_Raids;
::mods_hookBaseClass("factions/faction", function( object )
{
    /*local parentName = object.SuperName;

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
            ::RPGR_Raids.log(format("No eligible lair in proximity of spawned party %s.", _name));
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

        local timeModifier = 0.9 + ::Math.minf(2.0, ::World.getTime().Days * 0.014) * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()];
        local lairResources = lair.getResources() * timeModifier;

        if (lairResources - _resources <= ::RPGR_Raids.CampaignModifiers.AssignmentResourceThreshold)
        {
            ::RPGR_Raids.log(format("Lair resource count for %s with %.2f resources is insufficient compared to the initial value of %.2f.", lair.getName(), lairResources, _resources));
            return party;
        }

        local baseResources = lair.getFlags().get("BaseResources");
        local baseResourceModifier = baseResources >= 200 ? (baseResources <= 350 ? -0.005 * baseResources + 2.0 : 0.25) : 1.0;
        local resourceDifference = baseResourceModifier * (::RPGR_Raids.Mod.ModSettings.getSetting("RoamerResourceModifier").getValue() / 100.0) * (lairResources - _resources);
        ::RPGR_Raids.log(format("%s with troop count %i is eligible for reinforcement.", _name, party.getTroops().len()));
        local isReinforced = ::RPGR_Raids.assignTroops(party, _template, resourceDifference);

        if (!isReinforced)
        {
            ::RPGR_Raids.log("Could not find a suitable party template for roamer reinforcement within alloted execution time, aborting procedure.");
            return party;
        }

        ::RPGR_Raids.log(format("%s with new troop count %i has been reinforced with resource count %.2f.", _name, party.getTroops().len(), resourceDifference));

        if ((resourceDifference / _resources) * 100 >= ::RPGR_Raids.CampaignModifiers.AssignmentVanguardThresholdPercentage)
        {
            ::RPGR_Raids.initialiseVanguardParameters(party);
        }

        return party;
    }*/

    Raids.Standard.wrap(object, "spawnEntity", function( _party, _tile, _name, _uniqueName, _template, _resources )
    {
        if (::Math.rand(1, 100) > Raids.Standard.getSetting("RoamerScaleChance"))
        {
            return;
        }

        if (!Raids.Lairs.isFactionViable(this))
        {
            return;
        }

        if (_template == null)
        {
            return;
        }

        local lairs = Raids.Lairs.findLairCandidatesAtPosition(_party.getPos(), 1.0);

        if (lairs.len() == 0)
        {
            Raids.Standard.log(format("No eligible lair in proximity of spawned party %s.", _name));
            return;
        }

        local lair = lairs[0];

        if (Raids.Standard.getSetting("RoamerScaleAgitationRequirement") && lair.getFlags().get("Agitation") == Raids.Lairs.AgitationDescriptors.Relaxed)
        {
            return;
        }

        if (Raids.Lairs.isActiveContractLocation(lair))
        {
            return;
        }

        local lairResources = lair.getResources() * Raids.Lairs.getTimeModifier();

        if (lairResources - _resources <= Raids.Lairs.Parameters.ResourceThreshold)
        {
            Raids.Standard.log(format("Lair resource count for %s with %.2f resources is insufficient compared to the initial value of %.2f.", lair.getName(), lairResources, _resources));
            return;
        }

        local baseResourceModifier = Raids.Standard.getBaseResourceModifier(lair.getFlags().get("BaseResources"));
        local resourceDifference = baseResourceModifier * Raids.Standard.getPercentageSetting("RoamerResourceModifier") * (lairResources - _resources);
        Raids.Standard.log(format("%s with troop count %i is eligible for reinforcement.", _name, _party.getTroops().len()));
        local isReinforced = Raids.Lairs.assignTroops(_party, _template, resourceDifference);

        if (!isReinforced)
        {
            Raids.Standard.log("Could not find a suitable party template for roamer reinforcement within alloted execution time, aborting procedure.");
            return _party;
        }

        Raids.Standard.log(format("%s with new troop count %i has been reinforced with resource count %.2f.", _name, party.getTroops().len(), resourceDifference));

        if ((resourceDifference / _resources) * 100 >= Raids.Lairs.Parameters.VanguardThresholdPercentage)
        {
            Raids.Lairs.initialiseVanguardParameters(_party);
        }

        return _party;
    }, "overrideReturn");
});