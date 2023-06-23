::mods_hookExactClass("ai/world/orders/move_order", function( object )
{
    local parentName = object.SuperName;

    local oE_nullCheck = "onExecute" in object ? object.onExecute : null;
    object.onExecute = function( _entity, _hasChanged )
    {
        local vanilla_onExecute = oE_nullCheck == null ? this[parentName].onExecute(_entity, _hasChanged) : oE_nullCheck(_entity, _hasChanged);

        if (_entity.getFlags().get("IsCaravan") == false)
        {
            return vanilla_onExecute;
        }

        local activeContract = ::World.Contracts.getActiveContract();

        if (activeContract != null && "Caravan" in activeContract.m && activeContract.m.Caravan.get() == _entity) // TODO: test this
        {
            ::logInfo("Caravan was found to be the target of an active contract.");
            return vanilla_onExecute;
        }

        if (_entity.getFlags().get("CaravanWealth") != false || _entity.getFlags().get("CaravanCargo") != false) // TODO: remove this as it's redundant
        {
            ::logInfo("Caravan parameters already initialised.");
            return vanilla_onExecute;
        }

        ::logInfo("Assigning caravan parameters.");
        ::RPGR_Raids.initialiseCaravanParameters(_entity, ::World.FactionManager.getFaction(_entity.getFaction()).getNearestSettlement(_entity.getTile()));
        return vanilla_onExecute;
    }
})