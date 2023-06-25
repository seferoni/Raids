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
            ::logInfo("Flags uninitialised.");
            return tooltipArray;
        }

        if (!::RPGR_Raids.isPlayerInProximityTo(this.getTile()))
        {
            return tooltipArray;
        }

        local caravanCargo = flags.get("CaravanCargo");
        local cargoIconPath = ::RPGR_Raids.retrieveCaravanCargoIconPath(caravanCargo);

        if (cargoIconPath == null)
        {
            return tooltipArray;
        }

        local iconPath = "ui/icons/" + cargoIconPath;
        local id = 2;
        local type = "hint";

        tooltipArray.extend([
            ::RPGR_Raids.generateTooltipTableEntry(id, type, iconPath, ::RPGR_Raids.getDescriptor(caravanCargo, ::RPGR_Raids.CaravanCargoDescriptors)),
            ::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/bag.png", ::RPGR_Raids.getDescriptor(flags.get("CaravanWealth"), ::RPGR_Raids.CaravanWealthDescriptors))
        ]);

        return tooltipArray;
    }

    local oDLFP_nullCheck = "onDropLootForPlayer" in object ? object.onDropLootForPlayer : null;
    object.onDropLootForPlayer = function( _lootTable )
    {
        local vanilla_onDropLootForPlayer = oDLFP_nullCheck == null ? this[parentName].onDropLootForPlayer : oDLFP_nullCheck;
        local flags = this.getFlags();

        if (!::RPGR_Raids.isPartyEligible(flags))
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        if (!::RPGR_Raids.areCaravanFlagsInitialised(flags))
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        local isSouthern = ::World.FactionManager.getFaction(this.getFaction()).getType() == ::Const.FactionType.OrientalCityState;
        local retrievedCargo = ::RPGR_Raids.retrieveCaravanCargo(flags.get("CaravanCargo"), flags.get("CaravanWealth"), isSouthern);

        if (retrievedCargo.len() == 0)
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        foreach( item in retrievedCargo )
        {
            ::logInfo("Added " + item.getName() + " to the loot table.");
            item.onAddedToStash(null); // TODO: test this
            _lootTable.push(item);
        }

        return vanilla_onDropLootForPlayer(_lootTable);
    }
});