local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/party", function( object )
{
    Raids.Standard.wrap(object, "onCombatStarted", function()
    {
        if (!Raids.Shared.isPlayerInProximityTo(this.getTile()))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(this.getFlags().get("IsVanguard"), true);
    }, "overrideReturn");

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

    Raids.Standard.wrap(object, "getTooltip", function( _tooltipArray )
    {
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
        _tooltipArray.extend([
            Raids.Standard.makeTooltip(id, type, format("ui/icons/%s", cargoIconPath), Raids.Standard.getDescriptor(caravanCargo, Raids.Caravans.CargoDescriptors)),
            Raids.Standard.makeTooltip(id, type, "ui/icons/money2.png", Raids.Standard.getDescriptor(flags.get("CaravanWealth"), Raids.Caravans.WealthDescriptors))
        ]);

        if (flags.get("CaravanHasNamedItems"))
        {
            _tooltipArray.append(Raids.Standard.makeTooltip(id, type, "ui/icons/special.png", "Famed"));
        }

        return _tooltipArray;
    }, "overrideReturn")
});