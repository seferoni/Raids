::mods_hookBaseClass("contracts/contract", function( object )
{
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

        if (::RPGR_Raids.isLocationTypeEligible(destination.getLocationType()))
        {
            ::RPGR_Raids.setLairAgitation(destination, ::RPGR_Raids.Procedures.Reset);
        }

        return vanilla_start;
    }
});