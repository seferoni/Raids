::mods_hookBaseClass("factions/faction", function( object )
{
    local parentName = object.SuperName;

    local sE_nullCheck = "spawnEntity" in object ? object.spawnEntity : null;
    object.spawnEntity <- function( _tile, _name, _uniqueName, _template, _resources )
    {   // TODO: guard clause for scaling roamer setting to be written
        local party = sE_nullCheck == null ? this[parentName].spawnEntity(_tile, _name, _uniqueName, _template, _resources) : sE_nullCheck(_tile, _name, _uniqueName, _template, _resources);
        ::RPGR_Raids.logWrapper("spawnEntity called.");
        if (!::RPGR_Raids.isFactionViable(this))
        {
            ::RPGR_Raids.logWrapper("Faction " + ::RPGR_Raids.getDescriptor(this.getFaction(), ::Const.Factions) + " are not viable.");
            return party;
        }

        if (_template == null)
        {
            return party;
        }

        local lair = ::RPGR_Raids.getLairWithinProximityOf(_tile, this.getSettlements()); // return false when none in proximity

        if (lair == false)
        {
            ::RPGR_Raids.logWrapper("No lair in proximity of spawned party.", true);
            return party;
        }

        if (::RPGR_Raids.isActiveContractLocation(lair))
        {
            return party;
        }

        local lairResources = lair.getResources();

        if (lairResources <= _resources)
        {
            ::RPGR_Raids.logWrapper("Lair resource count for " + _lair.getName() + ", with " + lairResources + " resources, is currently insufficient compared to the initial value of " + _resources + ".");
            return party;
        }

        ::Const.World.Common.assignTroops(party, _template, lairResources - _resources); // TODO: test resource calc
        ::RPGR_Raids.logWrapper("[Raids] Party with name " + _name + " has been reinforced with resource count " + lairResources - _resources + ".");
        return party;
    }
});