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

        if (this.m.Destination.m.LocationType == ::Const.World.LocationType.Lair)
        {
            ::RPGR_Brigandage.setLairAgitation(this.m.Destination, ::RPGR_Brigandage.Procedures.Reset);
        }

        return fetch;
    }
});