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

        local lairResources = ::RPGR_Raids.getClosestLair(_tile).getResources();

        if (lairResources <= _resources)
        {
            return party;
        }

        ::Const.World.Common.assignTroops(party, _template, lairResources - _resources); // TODO: test resource calc
        return party;
    }
})