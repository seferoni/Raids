local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( _object )
{
    Raids.Standard.wrap(_object, "dropTreasure", function( _num, _items, _lootTable )
    {   // TODO: test this
        // TODO: hook ODLFP, rework loot distribution per agitation
        if (!Raids.Lairs.isLairViable(this))
        {
            return;
        }

        local offset = Raids.Edicts.getTreasureOffset(this);
        return [_num + offset, _items, _lootTable];
    }, "overrideArguments");

    Raids.Standard.wrap(_object, "onCombatStarted", function()
    {
        if (!Raids.Lairs.isLairViable(this, false, true))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(false);
    });

    Raids.Standard.wrap(_object, "onSpawned", function()
    {
        if (!Raids.Lairs.isLairViable(this))
        {
            return;
        }

        Raids.Lairs.initialiseLairParameters(this);

        if (Raids.Standard.getSetting("DepopulateLairLootOnSpawn"))
        {
            Raids.Lairs.depopulateNamedLoot(this, Raids.Lairs.Parameters.NamedItemChanceOnSpawn);
        }
    });

    Raids.Standard.wrap(_object, "getTooltip", function( _tooltipArray )
    {
        if (!Raids.Lairs.isLairViable(this, true, true))
        {
            return;
        }

        Raids.Lairs.updateAgitation(this);
        Raids.Edicts.updateEdicts(this);
        _tooltipArray.extend(Raids.Lairs.getTooltipEntries(this));
        _tooltipArray.extend(Raids.Edicts[format("get%sEntries", Raids.Edicts.isLairViable(this) ? "Tooltip" : "Nonviable")](this));
        return _tooltipArray;
    });
});