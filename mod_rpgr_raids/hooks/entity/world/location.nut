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
        ::RPGR_Raids.depopulateLairNamedLoot(this, ::RPGR_Raids.CampaignModifiers.NamedItemChanceOnSpawn);
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

        if (::RPGR_Raids.isActiveContractObject(this, "Location"))
        {
            ::logInfo(this.getName() + " was found to be an active contract location, aborting.");
            return tooltipArray;
        }

        local resources = this.m.Resources;
        local agitationState = this.getFlags().get("Agitation");
        local agitationDescriptor = ::RPGR_Raids.getDescriptor(agitationState, ::RPGR_Raids.AgitationDescriptors);

        tooltipArray.push({
            id = 20,
            type = "text",
            icon = "ui/icons/asset_money.png",
            text = "[color=" + ::Const.UI.Color.PositiveValue + "]" + resources + "[/color] resource units"
        });

        if (agitationState == ::RPGR_Raids.AgitationDescriptors.Relaxed)
        {
            tooltipArray.push({
                id = 20,
                type = "text",
                icon = "ui/icons/vision.png",
                text = "[color=" + ::Const.UI.Color.PositiveValue + "]" + agitationDescriptor + "[/color]"
            });
        }
        else
        {
            tooltipArray.push({
                id = 20,
                type = "text",
                icon = "ui/icons/miniboss.png",
                text = "[color=" + ::Const.UI.Color.NegativeValue + "]" + agitationDescriptor + "[/color]"
            });
        }

        ::RPGR_Raids.updateCumulativeLairAgitation(this);
        return tooltipArray;
    }
});