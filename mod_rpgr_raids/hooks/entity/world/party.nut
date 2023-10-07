local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/party", function( _object )
{
    Raids.Standard.wrap(_object, "onCombatStarted", function()
    {
        if (!Raids.Shared.isPlayerInProximityTo(this.getTile(), 1))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(this.getFlags().get("IsVanguard"), true);
    });

    Raids.Standard.wrap(_object, "onDropLootForPlayer", function( _lootTable )
    {
        local flags = this.getFlags();

        if (!Raids.Caravans.isPartyViable(this))
        {
            return;
        }

        if (!Raids.Caravans.areFlagsInitialised(flags))
        {
            return;
        }

        if (!flags.get("CaravanHasNamedItems"))
        {
            return;
        }

        Raids.Caravans.addNamedCargo(_lootTable);
        return _lootTable;
    }, "overrideArguments");

    Raids.Standard.wrap(_object, "getTooltip", function( _tooltipArray )
    {
        local flags = this.getFlags();

        if (!Raids.Caravans.isPartyViable(this))
        {
            return;
        }

        if (!Raids.Caravans.areFlagsInitialised(flags))
        {
            return;
        }

        _tooltipArray.extend([
            {id = 2, type = "hint", icon = format("ui/icons/%s", Raids.Caravans.getCargoIcon(flags.get("CaravanCargo"))), text = Raids.Standard.getDescriptor(flags.get("CaravanCargo"), Raids.Caravans.CargoDescriptors)},
            {id = 2, type = "hint", icon = "ui/icons/money2.png", text = Raids.Standard.getDescriptor(flags.get("CaravanWealth"), Raids.Caravans.WealthDescriptors)}
        ]);

        if (flags.get("CaravanHasNamedItems"))
        {
            _tooltipArray.push({id = 2, type = "hint", icon = "ui/icons/special.png", text = "Famed"});
        }

        return _tooltipArray;
    });
});