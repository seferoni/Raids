local Raids = ::RPGR_Raids;
::mods_hookBaseClass("contracts/contract", function( _object )
{
    Raids.Standard.wrap(_object, "start", function()
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
            Raids.Lairs.setAgitation(destination, Raids.Lairs.Procedures.Reset);
        }
    }, "overrideReturn");
});