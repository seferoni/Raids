local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/party", function( _object )
{
    Raids.Standard.wrap(_object, "onCombatStarted", function()
    {
        if (!Raids.Shared.isPlayerInProximityTo(this.getTile(), 1))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(Raids.Standard.getFlag("IsVanguard", this), true);
    });

    Raids.Standard.wrap(_object, "onDropLootForPlayer", function( _lootTable )
    {
        if (!Raids.Caravans.isPartyViable(this))
        {
            return;
        }

        if (!Raids.Caravans.isPartyInitialised(this))
        {
            return;
        }

        if (!Raids.Standard.getFlag("CaravanHasNamedItems", this))
        {
            return;
        }

        Raids.Caravans.addNamedCargo(_lootTable);
        return _lootTable;
    }, "overrideArguments");

    Raids.Standard.wrap(_object, "getTooltip", function( _tooltipArray )
    {
        if (!Raids.Caravans.isPartyViable(this))
        {
            return;
        }

        if (!Raids.Caravans.isPartyInitialised(this))
        {
            return;
        }

        _tooltipArray.extend([
            {id = 2, type = "hint", icon = format("ui/icons/%s", Raids.Caravans.getCargoIcon(Raids.Standard.getFlag("CaravanCargo", this))), text = Raids.Standard.getDescriptor(Raids.Standard.getFlag("CaravanCargo", this), Raids.Caravans.CargoDescriptors)},
            {id = 2, type = "hint", icon = "ui/icons/money2.png", text = Raids.Standard.getDescriptor(Raids.Standard.getFlag("CaravanWealth", this), Raids.Caravans.WealthDescriptors)}
        ]);

        if (Raids.Standard.getFlag("CaravanCargo", this))
        {
            _tooltipArray.push({id = 2, type = "hint", icon = "ui/icons/special.png", text = "Famed"});
        }

        return _tooltipArray;
    });
});