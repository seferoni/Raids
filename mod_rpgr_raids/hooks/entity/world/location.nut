local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( object )
{
    /*local parentName = object.SuperName;

    local oS_nullCheck = "onSpawned" in object ? object.onSpawned : null;
    object.onSpawned = function()
    {
        local vanilla_onSpawned = oS_nullCheck == null ? this[parentName].onSpawned() : oS_nullCheck();

        if (!::RPGR_Raids.isLocationTypeViable(this.getLocationType()))
        {
            return vanilla_onSpawned;
        }

        ::RPGR_Raids.initialiseLairParameters(this);

        if (::RPGR_Raids.Mod.ModSettings.getSetting("DepopulateLairLootOnSpawn").getValue())
        {
            ::RPGR_Raids.depopulateLairNamedLoot(this, ::RPGR_Raids.CampaignModifiers.LairNamedItemChanceOnSpawn);
        }

        return vanilla_onSpawned;
    }*/

    Raids.Standard.wrap(object, "onSpawned", function( ... )
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

    /*local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();

        if (!::RPGR_Raids.isLocationTypeViable(this.getLocationType()))
        {
            return tooltipArray;
        }

        if (!::RPGR_Raids.isPlayerInProximityTo(this.getTile()))
        {
            return tooltipArray;
        }

        if (::RPGR_Raids.isActiveContractLocation(this))
        {
            ::RPGR_Raids.log(format("%s was found to be an active contract location, aborting.", this.getName()));
            return tooltipArray;
        }

        ::RPGR_Raids.updateCumulativeLairAgitation(this);
        local agitationState = this.getFlags().get("Agitation");
        local id = 20;
        local type = "text";
        local textColour = agitationState == ::RPGR_Raids.AgitationDescriptors.Relaxed ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue;
        local iconPath = agitationState == ::RPGR_Raids.AgitationDescriptors.Relaxed ? "vision.png" : "miniboss.png";

        tooltipArray.extend([
            ::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/asset_money.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + this.m.Resources + "[/color] resource units"),
            ::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/" + iconPath, "[color=" + textColour + "]" + ::RPGR_Raids.getDescriptor(agitationState, ::RPGR_Raids.AgitationDescriptors) + "[/color]")
        ]);

        return tooltipArray;
    }*/

    Raids.Standard.wrap(object, "getTooltip", function( ... )
    {
        local tooltipArray = Raids.Standard.getOriginalResult(vargv);

        if (!Raids.Lairs.isLocationTypeViable(this.getLocationType()))
        {
            return tooltipArray;
        }

        if (!Raids.Shared.isPlayerInProximityTo(this.getTile()))
        {
            return tooltipArray;
        }

        if (Raids.Lairs.isActiveContractLocation(this))
        {
            Raids.Standard.log(format("%s was found to be an active contract location, aborting.", this.getName()));
            return tooltipArray;
        }

        Raids.Lairs.updateCumulativeLairAgitation(this);
        local agitationState = this.getFlags().get("Agitation"), id = 20, type = "text",
        textColour = agitationState == Raids.Lairs.AgitationDescriptors.Relaxed ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue,
        iconPath = agitationState == Raids.Lairs.AgitationDescriptors.Relaxed ? "vision.png" : "miniboss.png";

        tooltipArray.extend([
            Raids.Standard.generateTooltipTableEntry(id, type, "ui/icons/asset_money.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + this.m.Resources + "[/color] resource units"),
            Raids.Standard.generateTooltipTableEntry(id, type, "ui/icons/" + iconPath, "[color=" + textColour + "]" + Raids.getDescriptor(agitationState, Raids.AgitationDescriptors) + "[/color]")
        ]);

        return tooltipArray;
    }, "overrideReturn");
});