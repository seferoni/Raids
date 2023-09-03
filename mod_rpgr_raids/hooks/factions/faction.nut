::mods_hookBaseClass("factions/faction", function( object )
{
    local parentName = object.SuperName;

    local sE_nullCheck = "spawnEntity" in object ? object.spawnEntity : null;
    object.spawnEntity <- function( _tile, _name, _uniqueName, _template, _resources )
    {
        local party = sE_nullCheck == null ? this[parentName].spawnEntity(_tile, _name, _uniqueName, _template, _resources) : sE_nullCheck(_tile, _name, _uniqueName, _template, _resources);

        if (::Math.rand(1, 100) > ::RPGR_Raids.Mod.ModSettings.getSetting("RoamerScaleChance").getValue())
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

        local entities = ::World.getAllEntitiesAndOneLocationAtPos(party.getPos(), 1.0);
        local lairs = entities.filter(function( entityIndex, entity )
        {
            if (!::isKindOf(entity, "location"))
            {
                return false;
            }
            else if (!::RPGR_Raids.isLocationTypeEligible(entity.getLocationType()))
            {
                //::RPGR_Raids.logWrapper(entity.getName() + " is not an eligible lair.")
                ::RPGR_Raids.logWrapper(format("%s is not an eligible lair.", entity.getName()));
                return false;
            }

            return true;
        });

        if (lairs.len() == 0)
        {
            //::RPGR_Raids.logWrapper("No eligible lair in proximity of spawned party " + _name + ".");
            ::RPGR_Raids.logWrapper(format("No eligible lair in proximity of spawned party %s.", _name));
            return party;
        }

        local lair = lairs[0];

        if (::RPGR_Raids.Mod.ModSettings.getSetting("RoamerScaleAgitationRequirement").getValue() && lair.getFlags().get("Agitation") == ::RPGR_Raids.AgitationDescriptors.Relaxed)
        {
            return party;
        }

        if (::RPGR_Raids.isActiveContractLocation(lair))
        {
            return party;
        }

        local lairResources = lair.getResources();

        if (lairResources <= _resources)
        {
            //::RPGR_Raids.logWrapper("Lair resource count for " + lair.getName() + ", with " + lairResources + " resources, is insufficient compared to the initial value of " + _resources + ".");
            ::RPGR_Raids.logWrapper(format("Lair resource count for %s, with %f resources, is insufficient compared to the initial value of %f.", lair.getName(), lairResources, _resources));
            return party;
        }

        local resourceDifference = (::RPGR_Raids.Mod.ModSettings.getSetting("RoamerResourceModifier").getValue() / 100.0) * (lairResources - _resources);
        //::RPGR_Raids.logWrapper(_name + " with troop count " + party.getTroops().len() + " is eligible for reinforcement.");
        ::RPGR_Raids.logWrapper(format("%s with troop count %i is eligible for reinforcement.", _name, party.getTroops().len()));
        ::RPGR_Raids.assignTroops(party, _template, resourceDifference);
        //::RPGR_Raids.logWrapper(_name + " with new troop count " + party.getTroops().len() + " has been reinforced with resource count " + resourceDifference + ".");
        ::RPGR_Raids.logWrapper(format("%s with new troop count %i has been reinforced with resource count %f.", _name, party.getTroops().len(), resourceDifference));


        if ((resourceDifference / _resources) * 100 >= ::RPGR_Raids.CampaignModifiers.PartyReinforcementThresholdPercentage)
        {
            ::RPGR_Raids.logWrapper(format("%s are eligible to be Mighty.", _name));
            party.setName(format("Mighty %s", _name));
            party.getFlags().set("IsMighty", true);
        }

        return party;
    }
});