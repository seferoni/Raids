::mods_hookExactClass("factions/actions/send_supplies_action", function( object )
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
            ::logInfo("[Raids] onExecute found no caravans near " + this.m.Start.getName() + ".");
            return vanilla_onExecute;
        }

        ::logInfo("Assigning caravan parameters.");
        ::RPGR_Raids.initialiseCaravanParameters(caravan, this.m.Start);
        return vanilla_onExecute;
    }
})