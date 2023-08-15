::mods_hookBaseClass("factions/faction", function( object )
{
    local parentName = object.SuperName;

    local sE_nullCheck = "spawnEntity" in object ? object.spawnEntity : null;
    object.spawnEntity <- function( _tile, _name, _uniqueName, _template, _resources )
    {
        local party = sE_nullCheck == null ? this[parentName].spawnEntity(_tile, _name, _uniqueName, _template, _resources) : sE_nullCheck(_tile, _name, _uniqueName, _template, _resources);

        if (!::RPGR_Raids.Mod.ModSettings.getSetting("ScalingRoamers").getValue())
        {
            return party;
        }

        if (!::RPGR_Raids.isFactionViable(this))
        {
            return party;
        }

        if (_template == null)
        {
            return party;
        }

        local lair = ::RPGR_Raids.getLairWithinProximityOf(_tile, this.getSettlements());

        if (lair == false)
        {
            ::RPGR_Raids.logWrapper("No lair in proximity of spawned party " + _name + ".", true);
            return party;
        }

        if (::RPGR_Raids.isActiveContractLocation(lair))
        {
            return party;
        }

        local lairResources = lair.getResources();

        if (lairResources <= _resources)
        {
            ::RPGR_Raids.logWrapper("Lair resource count for " + lair.getName() + ", with " + lairResources + " resources, is insufficient compared to the initial value of " + _resources + ".");
            return party;
        }

        local resourceDifference = (::RPGR_Raids.Mod.ModSettings.getSetting("RoamerResourceModifier").getValue() / 100.0) * (lairResources - _resources);
        ::RPGR_Raids.logWrapper("Party with name " + _name + " and troop count " + party.getTroops().len() + " is eligible for reinforcement.");
        ::Const.World.Common.assignTroops(party, _template, resourceDifference); // TODO: test resource calc
        ::RPGR_Raids.logWrapper("Party with name " + _name + " and new troop count " + party.getTroops().len() + " has been reinforced with resource count " + resourceDifference + ".");
        return party;
    }
});