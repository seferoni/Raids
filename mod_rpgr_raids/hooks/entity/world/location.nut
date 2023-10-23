local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( _object )
{
    Raids.Standard.wrap(_object, "dropFood", function( _num, _items, _lootTable )
    {
        if (!Raids.Lairs.isLocationTypeViable(this.getLocationType()))
        {
            return;
        }
        
        local quantity = _num;

        if (!Raids.Edicts.findEdict("special.edict_of_abundance", this, true))
        {
            return;
        }

        quantity += Raids.Edicts.Parameters.AbundanceOffset;
        return [quantity, _items, _lootTable];
    }, "overrideArguments");


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