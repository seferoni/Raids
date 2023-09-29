local Raids = ::RPGR_Raids;
::mods_hookBaseClass("contracts/contract", function( object )
{
    /*local parentName = object.SuperName;

    local s_nullCheck = "start" in object ? object.start : null;
    object.start = function()
    {
        local vanilla_start = s_nullCheck == null ? this[parentName].start() : s_nullCheck();

        if (!("Destination" in this.m))
        {
            return vanilla_start;
        }

        local destination = this.m.Destination;

        if (destination == null)
        {
            return vanilla_start;
        }

        if (::RPGR_Raids.isLocationTypeViable(destination.getLocationType()))
        {
            ::RPGR_Raids.log(format("%s has been set as contract destination, performing agitation reset procedure.", destination.getName()));
            ::RPGR_Raids.setLairAgitation(destination, ::RPGR_Raids.Procedures.Reset);
        }

        return vanilla_start;
    }*/

    Raids.Standard.wrap(object, "start", function( ... )
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