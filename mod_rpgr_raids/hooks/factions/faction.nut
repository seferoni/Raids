::mods_hookBaseClass("factions/faction", function( object )
{
    local parentName = object.SuperName;

    local sE_nullCheck = "spawnEntity" in object ? object.spawnEntity : null;
    object.spawnEntity = function( _tile, _name, _uniqueName, _template, _resources )
    {
        local party = sE_nullCheck == null ? this[parentName].spawnEntity(_tile, _name, _uniqueName, _template, _resources) : sE_nullCheck(_tile, _name, _uniqueName, _template, _resources);

        if (!::RPGR_Raids.isFactionViable(this))
        {
            return party;
        }

        if (template == null)
        {
            return party;
        }

        local lair = ::RPGR_Raids.getLairWithinProximity(_tile); // return false when none in proximity

        if (lair == false)
        {
            return party;
        }

        if (::RPGR_Raids.isActiveContractLocation(lair))
        {
            return party;
        }

        local lairResources = lair.getResources();

        if (lairResources <= _resources)
        {
            return party;
        }

        ::Const.World.Common.assignTroops(party, _template, lairResources - _resources); // TODO: test resource calc
        return party;
    }
})