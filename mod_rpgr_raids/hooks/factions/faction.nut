local Raids = ::RPGR_Raids;
::mods_hookBaseClass("factions/faction", function( _object )
{
    Raids.Standard.wrap(_object, "spawnEntity", function( _party, _tile, _name, _uniqueName, _template, _resources )
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

        local lairs = Raids.Lairs.getCandidatesAtPosition(_party.getPos(), 1.0);

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

        if (lairResources - _resources <= Raids.Lairs.Parameters.VanguardResourceThreshold)
        {
            Raids.Standard.log(format("Lair resource count for %s with %.2f resources is insufficient compared to the initial value of %.2f.", lair.getName(), lairResources, _resources));
            return;
        }

        Raids.Standard.log(format("%s with troop count %i is eligible for reinforcement.", _name, _party.getTroops().len()));
        local resourceDifference = Raids.Lairs.getResourceDifference(lair, lairResources, _resources),
        isReinforced = Raids.Lairs.assignTroops(_party, _template, resourceDifference);

        if (!isReinforced)
        {
            Raids.Standard.log(format("Could not find a suitable party template for %s, aborting procedure.", _name));
            return _party;
        }

        Raids.Standard.log(format("%s with new troop count %i has been reinforced with resource count %.2f.", _name, _party.getTroops().len(), resourceDifference));

        if ((resourceDifference / _resources) * 100 >= Raids.Lairs.Parameters.VanguardThresholdPercentage)
        {
            Raids.Lairs.initialiseVanguardParameters(_party);
        }

        return _party;
    });
});