::mods_hookExactClass("entity/world/party", function( object )
{
    local parentName = object.SuperName;

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();
        local flags = this.getFlags();

        if (!::RPGR_Raids.isPartyEligible(flags))
        {
            return tooltipArray;
        }

        if (!::RPGR_Raids.areCaravanFlagsInitialised(flags))
        {
            return tooltipArray;
        }

        local id = 2;
        local type = "hint";

        tooltipArray.append(::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/bag.png", ::RPGR_Raids.getDescriptor(flags.get("CaravanWealth"), ::RPGR_Raids.CaravanWealthDescriptors)));

        if (flags.get("CaravanHasNamedItems"))
        {
            tooltipArray.append(::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/special.png", "Famed"));
        }

        return tooltipArray;
    }
});