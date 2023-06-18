::mods_hookExactClass("entity/world/party", function( object )
{
    local parentName = object.SuperName;

    local oD_nullCheck = "onDiscovered" in object ? object.onDiscovered : null;
    object.onDiscovered = function()
    {
        local vanilla_onDiscovered = oD_nullCheck == null ? this[parentName].onDiscovered() : oD_nullCheck()

        if (this.getFlags().get("IsCaravan") == false)
        {
            return vanilla_onDiscovered;
        }

        if (this.getFlags().get("CaravanWealth") != false || this.getFlags().get("CaravanCargo") != false)
        {
            return vanilla_onDiscovered;
        }

        ::logInfo("Assigning caravan parameters.");
        ::RPGR_Raids.initialiseCaravanParameters(this, ::World.FactionManager.getFaction(this.getFaction()).getNearestSettlement(this.getTile()));
        return vanilla_onDiscovered;
    }

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();

        if (this.getFlags().get("IsCaravan") == false)
        {
            return tooltipArray;
        }

        local iconPath = "ui/icons/";
        local flags = this.getFlags();
        local caravanWealth = flags.get("CaravanWealth");
        local caravanCargo = flags.get("CaravanCargo");

        if (caravanWealth == false || caravanCargo == false)
        {
            ::logInfo("Flags uninitialised.");
            return tooltipArray;
        }

        switch (caravanCargo)
        {
            case(::RPGR_Raids.CaravanCargoDescriptors.Oddities):
                iconPath += "perks.png"
                break;

            case (::RPGR_Raids.CaravanCargoDescriptors.Assortment):
                iconPath += "asset_supplies.png";
                break;

            case(::RPGR_Raids.CaravanCargoDescriptors.Trade):
                iconPath += "asset_business_reputation.png"
                break;

            case(::RPGR_Raids.CaravanCargoDescriptors.Rations):
                iconPath += "asset_food.png"
                break;

            default:
                ::logError("No matching caravan cargo descriptor found for caravan.");
                return tooltipArray;
        }

        local caravanWealthDescriptor = ::RPGR_Raids.getDescriptor(caravanWealth, ::RPGR_Raids.CaravanWealthDescriptors);
        local caravanCargoDescriptor = ::RPGR_Raids.getDescriptor(caravanCargo, ::RPGR_Raids.CaravanCargoDescriptors);

        tooltipArray.extend([
            {
                id = 2,
                type = "hint",
                icon = iconPath,
                text = caravanCargoDescriptor
            },
            {
                id = 2,
                type = "hint",
                icon = "ui/icons/bag.png",
                text = caravanWealthDescriptor
            }
        ]);

        return tooltipArray;
    }

    local oDLFP_nullCheck = "onDropLootForPlayer" in object ? object.onDropLootForPlayer : null;
    object.onDropLootForPlayer = function( _lootTable )
    {
        local vanilla_onDropLootForPlayer = oDLFP_nullCheck == null ? this[parentName].onDropLootForPlayer : oDLFP_nullCheck;
        local flags = this.getFlags();

        if (flags.get("IsCaravan") == false)
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        local retrievedCargo = ::RPGR_Raids.retrieveCaravanCargo(flags.get("CaravanCargo"), flags.get("CaravanWealth"));

        if (retrievedCargo.len() == 0)
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        foreach( item in retrievedCargo )
        {
            _lootTable.push(item);
        }

        return vanilla_onDropLootForPlayer(_lootTable);
    }
});