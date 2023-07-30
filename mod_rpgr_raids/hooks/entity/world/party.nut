::mods_hookExactClass("entity/world/party", function( object )
{
    local parentName = object.SuperName;

    local oCL_nullCheck = "onCombatLost" in object ? object.onCombatLost : null;
    object.onCombatLost = function()
    {
        local vanilla_onCombatLost = oCL_nullCheck == null ? this[parentName].onCombatFinished : oCL_nullCheck;

        if (::World.Statistics.getFlags().get("LastCombatWasArena"))
        {
            return vanilla_onCombatLost();
        }

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationIncrementChance").getValue())
        {
            return vanilla_onCombatLost();
        }

        local faction = ::World.FactionManager.getFaction(this.getFaction());

        if (!::RPGR_Raids.isFactionViable(faction))
        {
            ::RPGR_Raids.logWrapper("onCombatLost found no eligible factions.");
            return vanilla_onCombatLost();
        }

        if (faction.getSettlements().len() == 0)
        {
            ::RPGR_Raids.logWrapper("onCombatLost found an eligible faction, but this faction has no settlements at present.");
            return vanilla_onCombatLost();
        }

        ::RPGR_Raids.logWrapper("Proceeding to lair candidate selection.");
        local lairs = faction.getSettlements().filter(function( locationIndex, location )
        {
            return ::RPGR_Raids.isLocationEligible(location.getLocationType()) && ::RPGR_Raids.isPlayerInProximityTo(location.getTile());
        });

        if (lairs.len() == 0)
        {
            ::RPGR_Raids.logWrapper("onCombatLost could not find any lairs within proximity.");
            return vanilla_onCombatLost();
        }

        foreach( lair in lairs )
        {
            if (!::RPGR_Raids.isActiveContractLocation(lair))
            {
                ::RPGR_Raids.setLairAgitation(lair, ::RPGR_Raids.Procedures.Increment);
                ::RPGR_Raids.logWrapper("Found lair candidate.");
            }
        }

        return vanilla_onCombatLost();
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