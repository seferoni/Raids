local Raids = ::RPGR_Raids;
::mods_hookExactClass("factions/actions/send_supplies_action", function( object )
{
    /*local parentName = object.SuperName;

    local oE_nullCheck = "onExecute" in object ? object.onExecute : null;
    object.onExecute = function( _faction )
    {
        local vanilla_onExecute = oE_nullCheck == null ? this[parentName].onExecute(_faction) : oE_nullCheck(_faction);

        if (!::RPGR_Raids.Mod.ModSettings.getSetting("HandleSupplyCaravans").getValue())
        {
            return vanilla_onExecute;
        }

        local grossEntities = ::World.getAllEntitiesAtPos(this.m.Start.getPos(), 1.0);
        local caravan = null;

        foreach( entity in grossEntities )
        {
            local flags = entity.getFlags();

            if (::RPGR_Raids.isPartyViable(flags) && !::RPGR_Raids.areCaravanFlagsInitialised(flags))
            {
                caravan = entity;
            }
        }

        if (caravan == null)
        {
            ::RPGR_Raids.log(format("onExecute found no caravans near %s.", this.m.Start.getName()), true);
            return vanilla_onExecute;
        }

        ::RPGR_Raids.log("Assigning caravan parameters.");
        ::RPGR_Raids.initialiseCaravanParameters(caravan, this.m.Start);
        return vanilla_onExecute;
    }*/

    Raids.Standard.wrap(object, "onExecute", function( _originalResult, _faction )
    {
        if (!Raids.Standard.getSetting("HandleSupplyCaravans"))
        {
            return;
        }

        local grossEntities = ::World.getAllEntitiesAtPos(this.m.Start.getPos(), 1.0);
        local caravan = null;

        foreach( entity in grossEntities )
        {
            local flags = entity.getFlags();

            if (Raids.Caravans.isPartyViable(entity) && !Raids.Caravans.areCaravanFlagsInitialised(flags))
            {
                caravan = entity;
            }
        }

        if (caravan == null)
        {
            Raids.Standard.log(format("onExecute found no caravans near %s.", this.m.Start.getName()), true);
            return;
        }

        Raids.Standard.log("Assigning caravan parameters.");
        Raids.Caravans.initialiseCaravanParameters(caravan, this.m.Start);
    },"overrideReturn");
})