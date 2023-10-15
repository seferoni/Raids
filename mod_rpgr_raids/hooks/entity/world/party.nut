local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/party", function( _object )
{
    Raids.Standard.wrap(_object, "onCombatStarted", function()
    {
        if (!Raids.Shared.isPlayerInProximityTo(this.getTile(), 1))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(true);
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

        _tooltipArray.extend(Raids.Caravans.getCaravanEntries(this));
        return _tooltipArray;
    });
});