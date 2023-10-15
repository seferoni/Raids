local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( _object )
{
    Raids.Standard.wrap(_object, "onCombatStarted", function()
    {
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
        _tooltipArray.extend(Raids.Lairs.getLairEntries(this));
        _tooltipArray.extend(Raids.Edicts.getEdictEntries(this));
        return _tooltipArray;
    });
});