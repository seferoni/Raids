::mods_hookExactClass("factions/actions/send_caravan_action", function( object )
{
    local parentName = object.SuperName;

    local oE_nullCheck = "onExecute" in object ? object.onExecute : null;
    object.onExecute = function( _faction )
    {
        local vanilla_onExecute = oE_nullCheck == null ? this[parentName].onExecute(_faction) : oE_nullCheck(_faction);
        local grossEntities = ::World.getAllEntitiesAtPos(this.m.Start.getPos(), 1.0);
        local caravan = null;

        foreach( entity in grossEntities )
        {
            local flags = entity.getFlags();

            if (::RPGR_Raids.isPartyEligible(flags) && !::RPGR_Raids.areCaravanFlagsInitialised(flags))
            {
                caravan = entity;
            }
        }

        if (caravan == null)
        {
            ::RPGR_Raids.logWrapper(format("onExecute found no caravans near %s.", this.m.Start.getName()), true);
            return vanilla_onExecute;
        }

        ::RPGR_Raids.logWrapper("Assigning caravan parameters.");
        ::RPGR_Raids.initialiseCaravanParameters(caravan, this.m.Start);
        return vanilla_onExecute;
    }
});