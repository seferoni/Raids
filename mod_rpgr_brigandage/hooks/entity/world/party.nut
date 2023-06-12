::mods_hookExactClass("entity/world/party", function( object )
{
    local parentName = object.SuperName;

    local c_nullCheck = "create" in object ? object.create : null;
    object.create = function()
    {
        local vanilla_create = c_nullCheck == null ? this[parentName].create() : c_nullCheck()

        if (this.getFlags().get("IsCaravan") == false)
        {
            return vanilla_create;
        }

        ::RPGR_Brigandage.initialiseCaravanParameters(this, this.getFaction().getNearestSettlement(this.getTile()));
        return vanilla_create;
    }

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();

        if (this.getFlags().get("IsCaravan") == false)
        {
            return tooltipArray;
        }

        if (::RPGR_Brigandage.Mod.ModSettings.getSetting("ModifyTooltip").getValue() == false)
        {
            return tooltipArray;
        }

        local flags = this.getFlags();
        local caravanWealthDescriptor = ::RPGR_Brigandage.getDescriptor(flags.get("CaravanWealth"), ::RPGR_Brigandage.CaravanWealthDescriptors);
        local caravanCargoDescriptor = ::RPGR_Brigandage.getDescriptor(flags.get("CaravanWealth"), ::RPGR_Brigandage.CaravanCargoDescriptors);

        if (caravanWealth == false || caravanGoods == false)
        {
            return tooltipArray;
        }

        tooltipArray.extend([
        {
            id = 50,
            type = "hint",
            icon = "ui/icons/bag.png",
            text = caravanCargoDescriptor
        },
        {
            id = 50,
            type = "hint",
            icon = "ui/icons/money.png",
            text = caravanWealthDescriptor
        }]);

        return tooltipArray;
    }

    local oDLFP_nullCheck = "onDropLootForPlayer" in object ? object.onDropLootForPlayer : null;
    object.onDropLootForPlayer = function( _lootTable )
    {
        local vanilla_onDropLootForPlayer = oDLFP_nullCheck == null ? this[parentName].onDropLootForPlayer : oDLFP_nullCheck;
        local flags = this.getFlags();

        if (flags().get("IsCaravan") == false)
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        local retrievedCargo = ::RPGR_Brigandage.retrieveCaravanCargo(flags.get("CaravanCargo"), flags.get("CaravanWealth"));

        foreach ( item in retrievedCargo )
        {
            _lootTable.push(item);
        }

        // TODO: bolster troop count by wealth
        return vanilla_onDropLootForPlayer(_lootTable);
    }
});