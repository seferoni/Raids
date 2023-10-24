local Raids = ::RPGR_Raids;
::mods_hookBaseClass("factions/faction", function( _object )
{
    Raids.Standard.wrap(_object, "spawnEntity", function( _tile, _name, _uniqueName, _template, _resources )
    {
        if (::Math.rand(1, 100) > Raids.Standard.getSetting("RoamerScaleChance"))
        {
            return;
        }

        if (Raids.Lairs.Factions.find(this.getType()) == null)
        {
            return;
        }

        if (_template == null)
        {
            return;
        }

        local lair = Raids.Lairs.getCandidateAtPosition(_tile.Coords);

        if (lair == null)
        {
            Raids.Standard.log(format("No eligible lair in proximity of party %s.", _name));
            return;
        }

        if (Raids.Standard.getSetting("RoamerScaleAgitationRequirement") && Raids.Standard.getFlag("Agitation", lair) == Raids.Lairs.AgitationDescriptors.Relaxed)
        {
            return;
        }

        local resourceDifference = Raids.Lairs.getResourceDifference(lair, lair.getResources() * Raids.Lairs.getTimeModifier(), _resources);
        Raids.Standard.log(format("%s has been reinforced with resource count %.2f.", resourceDifference));
        return [_tile, _name, _uniqueName, _template, _resources + resourceDifference];
    }, "overrideArguments");
});