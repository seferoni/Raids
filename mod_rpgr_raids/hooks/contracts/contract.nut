::mods_hookBaseClass("contracts/contract", function( object )
{
    local vanilla_start = object.start;
    object.start = function()
    {
        local fetch = vanilla_start();

        if (!("Destination" in this.m))
        {
            return fetch;
        }

        if (this.m.Destination == null)
        {
            return fetch;
        }

        if (::RPGR_Raids.isLocationEligible(this.m.Destination.getLocationType()))
        {
            ::RPGR_Raids.setLairAgitation(this.m.Destination, ::RPGR_Raids.Procedures.Reset);
        }

        return fetch;
    }
});