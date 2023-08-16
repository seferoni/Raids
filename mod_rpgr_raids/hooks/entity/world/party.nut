::mods_hookExactClass("entity/world/party", function( object )
{
    local parentName = object.SuperName;

    local oCS_nullCheck = "onCombatStarted" in object ? object.onCombatStarted : null;
    object.onCombatStarted = function()
    {
        ::RPGR_Raids.logWrapper("onCombatStarted called.");
        local vanilla_onCombatStarted = oCS_nullCheck == null ? this[parentName].onCombatStarted : oCS_nullCheck;

        if (::World.Statistics.getFlags().get("LastCombatWasArena")) // TODO: test this
        {
            return vanilla_onCombatStarted();
        }

        if (!::RPGR_Raids.isPlayerInProximityTo(this.getTile()))
        {
            ::RPGR_Raids.logWrapper("Player not in proximity to attacked party, aborting.");
            return vanilla_onCombatStarted();
        }

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationIncrementChance").getValue())
        {
            return vanilla_onCombatStarted();
        }

        local faction = ::World.FactionManager.getFaction(this.getFaction());

        if (faction == null)
        {
            return vanilla_onCombatStarted();
        }

        if (!::RPGR_Raids.isFactionViable(faction))
        {
            return vanilla_onCombatStarted();
        }

        local faction = ::World.FactionManager.getFaction(this.getFaction());

        if (faction == null)
        {
            return vanilla_onCombatStarted();
        }

        local lairs = ::RPGR_Raids.findLairCandidates(faction);

        if (lairs == null)
        {
            return vanilla_onCombatStarted();
        }

        ::RPGR_Raids.agitateViableLairs(lairs);
        return vanilla_onCombatStarted();
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

        if (!flags.get("CaravanHasNamedItems"))
        {
            return vanilla_onDropLootForPlayer(_lootTable);
        }

        ::RPGR_Raids.retrieveNamedCaravanCargo(_lootTable);
        return vanilla_onDropLootForPlayer(_lootTable);
    }

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
    }
});