::mods_hookExactClass("entity/world/location", function( object )
{
    local parentName = object.SuperName;

    local oS_nullCheck = "onSpawned" in object ? object.onSpawned : null;
    object.onSpawned = function()
    {
        local vanilla_onSpawned = oS_nullCheck == null ? this[parentName].onSpawned() : oS_nullCheck();

        if (!::RPGR_Raids.isLocationEligible(this.getLocationType()))
        {
            return vanilla_onSpawned;
        }

        local flags = this.getFlags();
        flags.set("BaseResources", this.m.Resources);
        flags.set("Agitation", ::RPGR_Raids.AgitationDescriptors.Relaxed);

        if (::RPGR_Raids.Mod.ModSettings.getSetting("DepopulateLairLootOnSpawn").getValue() == true)
        {
            ::RPGR_Raids.depopulateLairNamedLoot(this, ::RPGR_Raids.CampaignModifiers.NamedItemChanceOnSpawn);
        }

        return vanilla_onSpawned;
    }

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();

        if (!::RPGR_Raids.isLocationEligible(this.getLocationType()))
        {
            return tooltipArray;
        }

        if (!::RPGR_Raids.isPlayerInProximityTo(this.getTile()))
        {
            return tooltipArray;
        }

        if (::RPGR_Raids.isActiveContractLocation(this))
        {
            ::logInfo(this.getName() + " was found to be an active contract location, aborting.");
            return tooltipArray;
        }

        ::RPGR_Raids.updateCumulativeLairAgitation(this); // TODO: test where this needs to be called
        local agitationState = this.getFlags().get("Agitation");
        local id = 20;
        local type = "text";
        local iconPath = agitationState == ::RPGR_Raids.AgitationDescriptors.Relaxed ? "vision.png" : "miniboss.png";
        local textColour = agitationState == ::RPGR_Raids.AgitationDescriptors.Relaxed ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue;

        tooltipArray.extend([
            ::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/asset_money.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + this.m.Resources + "[/color] resource units"),
            ::RPGR_Raids.generateTooltipTableEntry(id, type, "ui/icons/" + iconPath, "[color=" + textColour + "]" + ::RPGR_Raids.getDescriptor(agitationState, ::RPGR_Raids.AgitationDescriptors) + "[/color]")
        ]);

        return tooltipArray;
    }
});