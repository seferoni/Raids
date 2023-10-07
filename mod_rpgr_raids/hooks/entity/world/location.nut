local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( _object )
{
    Raids.Standard.wrap(_object, "onCombatStarted", function()
    {
        if (!Raids.Shared.isPlayerInProximityTo(this.getTile(), 1))
        {
            return;
        }

        Raids.Lairs.updateCombatStatistics(false, false);
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
        local agitationState = this.getFlags().get("Agitation"),
        textColour = "PositiveValue", iconPath = "vision.png";
        if (agitationState != Raids.Lairs.AgitationDescriptors.Relaxed) textColour = "NegativeValue", iconPath = "miniboss.png";

        _tooltipArray.extend([
            {id = 20, type = "text", icon = "ui/icons/asset_money.png", text = format("%s resource units", Raids.Standard.colourWrap(format("%i", this.m.Resources), "PositiveValue"))},
            {id = 20, type = "text", icon = format("ui/icons/%s", iconPath), text = format("%s", Raids.Standard.colourWrap(format("%s", Raids.Standard.getDescriptor(agitationState, Raids.Lairs.AgitationDescriptors)), textColour))}
        ]);

        return _tooltipArray;
    });
});