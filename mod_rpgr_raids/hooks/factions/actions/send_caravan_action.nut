local Raids = ::RPGR_Raids;
::mods_hookExactClass("factions/actions/send_caravan_action", function( _object )
{
    Raids.Standard.wrap(_object, "onExecute", function( _faction )
    {
        local grossEntities = ::World.getAllEntitiesAtPos(this.m.Start.getPos(), 1.0);
        local caravan = null;

        foreach( entity in grossEntities )
        {
            if (Raids.Caravans.isPartyViable(entity) && !Raids.Caravans.isPartyInitialised(entity))
            {
                caravan = entity;
            }
        }

        if (caravan == null)
        {
            Raids.Standard.log(format("onExecute found no caravans near %s.", this.m.Start.getName()), true);
            return;
        }

        Raids.Caravans.initialiseCaravanParameters(caravan, this.m.Start);
    });
});