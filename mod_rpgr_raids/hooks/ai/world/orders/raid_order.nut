::mods_hookExactClass("ai/world/orders/raid_order", function( object )
{
    local parentName = object.SuperName;

    local oE_nullCheck = "onExecute" in object ? object.onExecute : null;
    object.onExecute = function( _entity, _hasChanged )
    {
        local vanilla_onExecute = oE_nullCheck == null ? this[parentName].onExecute(_entity, _hasChanged) : oE_nullCheck(_entity,_hasChanged);
        // need to get parent location if target is an attached location, which it certainly is

        local entities = this.World.getAllEntitiesAndOneLocationAtPos(_entity.getPos(), 1.0);

        foreach( e in entities )
        {
            if (e.isLocation() && e.getSettlement() != null && !e.getSettlement().isNull() && e.getSettlement().isAlive())
            {
                local settlementName = e.getSettlement().getName();
                ::logInfo("Raid order called on " + settlementName + ".");
            }
        }

        return vanilla_onExecute;
    }
})