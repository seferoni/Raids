local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/party", function( object )
{
    /*local parentName = object.SuperName;

    local oCS_nullCheck = "onCombatStarted" in object ? object.onCombatStarted : null;
    object.onCombatStarted = function()
    {
        local vanilla_onCombatStarted = oCS_nullCheck == null ? this[parentName].onCombatStarted() : oCS_nullCheck();

        if (!::RPGR_Raids.isPlayerInProximityTo(this.getTile()))
        {
            return vanilla_onCombatStarted;
        }

        ::RPGR_Raids.updateCombatStatistics([this.getFlags().get("IsVanguard"), true]);
        return vanilla_onCombatStarted;
    }*/

    Raids.Standard.wrap(object, "onCombatStarted", function( ... )
    {
        if (!Raids.Shared.isPlayerInProximityTo(this.getTile()))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(this.getFlags().get("IsVanguard"), true);
    }, "overrideReturn");

    /*local oDLFP_nullCheck = "onDropLootForPlayer" in object ? object.onDropLootForPlayer : null;
    object.onDropLootForPlayer = function( _lootTable )
    {
        local vanilla_onDropLootForPlayer = oDLFP_nullCheck == null ? this[parentName].onDropLootForPlayer : oDLFP_nullCheck;
        local flags = this.getFlags();

        if (!::RPGR_Raids.isPartyViable(flags))
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        if (!::RPGR_Raids.areCaravanFlagsInitialised(flags))
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        if (!flags.get("CaravanHasNamedItems"))
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        ::RPGR_Raids.retrieveNamedCaravanCargo(_lootTable);
        return vanilla_onDropLootForPlayer(_lootTable);
    }*/

    Raids.Standard.wrap(object, "onDropLootForPlayer", function( _lootTable )
    {
        local flags = this.getFlags();

        if (!Raids.Caravans.isPartyViable(this))
        {
            return;
        }

        if (!Raids.Caravans.areCaravanFlagsInitialised(flags))
        {
            return;
        }

        if (!flags.get("CaravanHasNamedItems"))
        {
            return;
        }

        Raids.Caravans.retrieveNamedCaravanCargo(_lootTable);
        return _lootTable;
    }, "overrideArguments");

    /*local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();
        local flags = this.getFlags();

        if (!::RPGR_Raids.isPartyViable(flags))
        {
            return tooltipArray;
        }

        if (!::RPGR_Raids.areCaravanFlagsInitialised(flags))
        {
            return tooltipArray;
        }

        local caravanCargo = flags.get("CaravanCargo");
        local cargoIconPath = ::RPGR_Raids.retrieveCaravanCargoIconPath(caravanCargo);

        if (cargoIconPath == null)
        {
            return tooltipArray;
        }

        local id = 2;
        local type = "hint";

        tooltipArray.extend([
            ::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/" + cargoIconPath, ::RPGR_Raids.getDescriptor(caravanCargo, ::RPGR_Raids.CaravanCargoDescriptors)),
            ::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/money2.png", ::RPGR_Raids.getDescriptor(flags.get("CaravanWealth"), ::RPGR_Raids.CaravanWealthDescriptors))
        ]);

        if (flags.get("CaravanHasNamedItems"))
        {
            tooltipArray.append(::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/special.png", "Famed"));
        }

        return tooltipArray;
    }*/

    Raids.Standard.wrap(object, "getTooltip", function( ... )
    {
        local tooltipArray = Raids.Standard.getOriginalResult(vargv), flags = this.getFlags();

        if (!Raids.Caravans.isPartyViable(this))
        {
            return;
        }

        if (!Raids.Caravans.areCaravanFlagsInitialised(flags))
        {
            return;
        }

        local caravanCargo = flags.get("CaravanCargo"), cargoIconPath = Raids.Caravans.retrieveCaravanCargoIconPath(caravanCargo);

        if (cargoIconPath == null)
        {
            return;
        }

        local id = 2, type = "hint";
        tooltipArray.extend([
            Raids.Standard.generateTooltipTableEntry(id, type, format("ui/icons/%s", cargoIconPath), Raids.Standard.getDescriptor(caravanCargo, Raids.Caravans.CargoDescriptors)),
            Raids.Standard.generateTooltipTableEntry(id, type, "ui/icons/money2.png", Raids.Standard.getDescriptor(flags.get("CaravanWealth"), Raids.Caravans.WealthDescriptors))
        ]);

        if (flags.get("CaravanHasNamedItems"))
        {
            tooltipArray.append(Raids.Standard.generateTooltipTableEntry(id, type, "ui/icons/special.png", "Famed"));
        }

        return tooltipArray;
    }, "overrideReturn")
});