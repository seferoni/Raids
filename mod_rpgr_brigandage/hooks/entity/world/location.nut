::mods_hookExactClass("entity/world/location", function( object )
{ // TODO: figure out how to repopulate loot pools after each agitation increment
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
        this.m.Resources = ::Math.floor(this.getFlags().get("BaseResources") / 2);
        this.getFlags().set("Agitation", ::RPGR_Brigandage.AgitationDescriptors.Relaxed);

        if (this.getLoot().isEmpty())
        {
            return vanilla_onSpawned;
        }

        if (::Math.rand(1, 100) <= ::RPGR_Brigandage.CampaignModifiers.FamedChanceOnCampSpawn)
        {
            ::logInfo("Bailing out for named item removal.");
            return vanilla_onSpawned;
        }

        local garbage = [];
        local items = this.getLoot().getItems();

        foreach( item in items )
        {
            if (item.isItemType(::Const.Items.ItemType.Named))
            {
                garbage.push(item);
            }
        }

        foreach( item in garbage )
        {
            local index = items.find(item);
            items.remove(index); // TODO: check if this works lol
            ::logInfo("Removed " + item.m.Name + " at index " + index + ".");
        }

        return vanilla_onSpawned;
    }

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip = function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();
        local activeContract = ::World.Contracts.getActiveContract();

        if (this.m.LocationType != ::Const.World.LocationType.Lair)
        {
            return tooltipArray;
        }

        if (activeContract != null && activeContract.m.Destination == this) // TODO: test this
        {
            ::logInfo(this.getName() + " was found to be an active contract location, aborting.");
            return tooltipArray;
        }

        local resources = this.m.Resources;
        local agitationState = this.getFlags().get("Agitation");
        local agitationDescriptor = ::RPGR_Brigandage.getAgitationDescriptor(agitationState);

        tooltipArray.push({
            id = 20,
            type = "text",
            icon = "ui/icons/asset_money.png",
            text = "[color=" + ::Const.UI.Color.PositiveValue + "]" + resources + "[/color] resource units"
        });

        if (agitationState == ::RPGR_Brigandage.AgitationDescriptors.Relaxed)
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

        local lastUpdateTime = this.getFlags().get("LastUpdateTime");

        if (lastUpdateTime == false)
        {
            return tooltipArray;
        }

        if (::World.getTime().Days - lastUpdateTime < ::RPGR_Brigandage.Mod.ModSettings.getSetting("AgitationDecayInterval").getValue())
        {
            return tooltipArray;
        }

        if (agitationState == ::RPGR_Brigandage.AgitationDescriptors.Relaxed)
        {
            return tooltipArray;
        }

        ::RPGR_Brigandage.setLairAgitation(this, ::RPGR_Brigandage.Procedures.Decrement);
        return tooltipArray;
    }
});