local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( _object )
{
    local stackables = ["Ammo", "ArmorParts", "Medicine"];

    foreach( stackable in stackables )
    {
        Raids.Standard.wrap(_object, format("drop%s", stackable), function( _num, _lootTable )
        {
            if (!Raids.Lairs.isLocationTypeViable(this.getLocationType()))
            {
                return;
            }

            if (Raids.Lairs.isActiveContractLocation(this))
            {
                return;
            }

            return [Raids.Lairs.getScaledLootCount(this, _num, null, _lootTable, true), _lootTable];
        }, "overrideArguments");
    }

    Raids.Standard.wrap(_object, "onCombatStarted", function()
    {
        if (!Raids.Lairs.isLocationTypeViable(this.getLocationType()))
        {
            return;
        }

        if (!Raids.Shared.isPlayerInProximityTo(this.getTile(), 1))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(false);
    });

    Raids.Standard.wrap(_object, "onSpawned", function()
    {
        if (!Raids.Lairs.isLocationTypeViable(this.getLocationType()))
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
        if (!Raids.Lairs.isLocationTypeViable(this.getLocationType()))
        {
            return;
        }

        if (!Raids.Shared.isPlayerInProximityTo(this.getTile()))
        {
            return;
        }

        if (Raids.Lairs.isActiveContractLocation(this))
        {
            Raids.Standard.log(format("%s was found to be an active contract location, aborting.", this.getName()));
            return;
        }

        Raids.Lairs.updateAgitation(this);
        Raids.Edicts.updateEdicts(this);
        _tooltipArray.extend(Raids.Lairs.getTooltipEntries(this));
        _tooltipArray.extend(Raids.Edicts.getTooltipEntries(this));
        return _tooltipArray;
    });
});