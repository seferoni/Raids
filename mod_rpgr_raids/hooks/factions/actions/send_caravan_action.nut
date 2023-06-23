::mods_hookExactClass("factions/actions/send_caravan_action", function( object )
{
    local parentName = object.SuperName;

    local oE_nullCheck = "onExecute" in object ? object.onExecute : null;
    object.onExecute = function( _faction )
    { // TODO: do the same thing for send_supplies for supply caravans
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
            ::logInfo("Caravan not located.");
            return vanilla_onExecute;
        }

        local activeContract = ::World.Contracts.getActiveContract();

        if (activeContract != null && "Caravan" in activeContract.m && activeContract.m.Caravan.get() == caravan) // TODO: test this
        {
            ::logInfo("Caravan was found to be the target of an active contract.");
            return vanilla_onExecute;
        }

        ::logInfo("Assigning caravan parameters.");
        ::RPGR_Raids.initialiseCaravanParameters(caravan, this.m.Start);
        return vanilla_onExecute;
    }
})