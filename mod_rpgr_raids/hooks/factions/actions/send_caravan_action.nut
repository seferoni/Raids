::mods_hookExactClass("factions/actions/send_caravan_action", function( object )
{
    Raids.Standard.wrap(object, "onExecute", function( _faction )
    {
        local grossEntities = ::World.getAllEntitiesAtPos(this.m.Start.getPos(), 1.0);
        local caravan = null;

        foreach( entity in grossEntities )
        {
            if (Raids.Caravans.isPartyViable(entity) && !Raids.Caravans.areFlagsInitialised(entity.getFlags()))
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
});