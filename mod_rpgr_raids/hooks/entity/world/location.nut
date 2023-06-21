::mods_hookExactClass("entity/world/location", function( object )
{
    local parentName = object.SuperName;

    local oS_nullCheck = "onSpawned" in object ? object.onSpawned : null;
    object.onSpawned = function()
    {
        local vanilla_onSpawned = oS_nullCheck == null ? this[parentName].onSpawned() : oS_nullCheck();

        if (this.m.LocationType != ::Const.World.LocationType.Lair)
        {
            return vanilla_onSpawned;
        }

        this.getFlags().set("BaseResources", this.m.Resources);
        this.getFlags().set("Agitation", ::RPGR_Raids.AgitationDescriptors.Relaxed);
        ::RPGR_Raids.depopulateLairNamedLoot(this, ::RPGR_Raids.CampaignModifiers.FamedChanceOnCampSpawn);
        return vanilla_onSpawned;
    }

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();

        if (this.getLocationType() != ::Const.World.LocationType.Lair)
        {
            return tooltipArray;
        }

        local activeContract = ::World.Contracts.getActiveContract();

        if (activeContract != null && "Destination" in activeContract.m && activeContract.m.Destination == this) // TODO: test this
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

        return tooltipArray;
    }

    local oU_nullCheck = "onUpdate" in object ? object.onUpdate : null;
    object.onUpdate <- function()
    {
        local vanilla_onUpdate = oU_nullCheck == null ? this[parentName].onUpdate() : oU_nullCheck();

        if (this.getLocationType() != ::Const.World.LocationType.Lair)
        {
            return vanilla_onUpdate;
        }

        ::logInfo("onUpdate called.");
        if (this.getFlags().get("Agitation") == ::RPGR_Raids.AgitationDescriptors.Relaxed)
        {
            return vanilla_onUpdate;
        }

        local lastUpdateTime = this.getFlags().get("LastAgitationUpdate");

        if (lastUpdateTime == false)
        {
            return vanilla_onUpdate;
        }

        if (::World.getTime().Days - lastUpdateTime < ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationDecayInterval").getValue())
        {
            return vanilla_onUpdate;
        }

        ::RPGR_Raids.setLairAgitation(this, ::RPGR_Raids.Procedures.Decrement);
        return vanilla_onUpdate;
    }
});