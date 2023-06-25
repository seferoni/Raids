::mods_hookExactClass("factions/actions/send_caravan_action", function( object )
{
    local parentName = object.SuperName;

    local oE_nullCheck = "onExecute" in object ? object.onExecute : null;
    object.onExecute = function( _faction )
    {
        ::logInfo("onExecute firing.");
        local vanilla_onExecute = oE_nullCheck == null ? this[parentName].onExecute(_faction) : oE_nullCheck(_faction);
        local grossEntities = ::World.getAllEntitiesAtPos(this.m.Start.getPos(), 1.0);
        local caravan = null;

        foreach( entity in grossEntities )
        {
            local flags = entity.getFlags();

            if (flags.get("IsCaravan") && (flags.get("CaravanCargo") == false && flags.get("CaravanWealth") == false))
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