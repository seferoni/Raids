local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( _object )
{
    foreach( stackable in ["Ammo", "ArmorParts", "Medicine"] ) // TODO: revise this
    {
        Raids.Standard.wrap(_object, format("drop%s", stackable), function( _num, _lootTable )
        {
            if (!Raids.Lairs.isLairViable(this))
            {
                return;
            }

        }, "overrideArguments");
    }

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
            Raids.Lairs.depopulateLairNamedLoot(this, Raids.Lairs.Parameters.NamedItemChanceOnSpawn);
        }
    });

    Raids.Standard.wrap(_object, "getTooltip", function( _tooltipArray )
    {
        if (!Raids.Lairs.isLairViable(this, true, true))
        {
            return;
        }

        Raids.Lairs.updateAgitation(this);
        Raids.Edicts.updateEdicts(this); // TODO: is this the right order?
        _tooltipArray.extend(Raids.Lairs.getTooltipEntries(this));
        _tooltipArray.extend(Raids.Edicts.getTooltipEntries(this));
        return _tooltipArray;
    });
});