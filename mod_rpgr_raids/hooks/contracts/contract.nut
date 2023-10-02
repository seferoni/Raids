local Raids = ::RPGR_Raids;
::mods_hookBaseClass("contracts/contract", function( object )
{
    Raids.Standard.wrap(object, "start", function()
    {
        if (!("Destination" in this.m))
        {
            return;
        }

        local destination = this.m.Destination;

        if (destination == null)
        {
            return;
        }

        if (Raids.Lairs.isLocationTypeViable(destination.getLocationType()))
        {
            Raids.Standard.log(format("%s has been set as current contract destination, performing agitation reset procedure.", destination.getName()));
            Raids.Lairs.setLairAgitation(destination, Raids.Procedures.Reset);
        }

        return;
    }, "overrideReturn");
});