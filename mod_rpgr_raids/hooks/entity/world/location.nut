local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( object )
{
    Raids.Standard.wrap(object, "onSpawned", function()
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

        return;
    }, "overrideReturn");

    Raids.Standard.wrap(object, "getTooltip", function( _tooltipArray )
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

        Raids.Lairs.updateCumulativeLairAgitation(this);
        local agitationState = this.getFlags().get("Agitation"), id = 20, type = "text",
        textColour = agitationState == Raids.Lairs.AgitationDescriptors.Relaxed ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue,
        iconPath = agitationState == Raids.Lairs.AgitationDescriptors.Relaxed ? "vision.png" : "miniboss.png";

        _tooltipArray.extend([
            Raids.Standard.makeTooltip(id, type, "ui/icons/asset_money.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + this.m.Resources + "[/color] resource units"), // TODO: colour wrap these
            Raids.Standard.makeTooltip(id, type, format("ui/icons/%s", iconPath), "[color=" + textColour + "]" + Raids.getDescriptor(agitationState, Raids.AgitationDescriptors) + "[/color]")
        ]);

        return _tooltipArray;
    }, "overrideReturn");
});