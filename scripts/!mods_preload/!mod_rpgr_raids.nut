::RPGR_Raids <-
{
    ID = "mod_rpgr_raids",
    Name = "RPG Rebalance - Raids",
    Version = 1.0.0,
    Internal =
    {
        TERMINATE = "__end"
    }
    Defaults =
    {   // TODO: revise these when done
        AgitationIncrementChance = 100,
        AgitationResourceModifier = 70,
        CaravanReinforcementChance = 100,
        DepopulateLairLootOnSpawn = true,
        FactionSpecificNamedLootChance = 33,
        OfficialDocumentDropChance = 35,
        RoamerScaleChance = 100,
        RoamerResourceModifier = 70,
        RoamerScaleAgitationRequirement = false,
        VerboseLogging = false
    }
}

local Raids = ::RPGR_Raids;
::mods_registerMod(Raids.ID, Raids.Version, Raids.Name);
::mods_queue(Raids.ID, ">mod_msu", function()
{
    Raids.Internal.MSUFound <- ::mods_getRegisteredMod("mod_msu") != null;

    if (!Raids.Internal.MSUFound)
    {
        return;
    }

    Raids.Mod <- ::MSU.Class.Mod(Raids.ID, Raids.Version, Raids.Name);

    local pageGeneral = Raids.Mod.ModSettings.addPage("General");
    local pageLairs = Raids.Mod.ModSettings.addPage("Lairs");
    local pageCaravans = Raids.Mod.ModSettings.addPage("Caravans");

    local agitationIncrementChance = pageLairs.addRangeSetting("AgitationIncrementChance", 100, 0, 100, 1, "Agitation Increment Chance");
    agitationIncrementChance.setDescription("Determines the chance for a location's agitation value to increase upon engagement with a roaming party, if within proximity.");

    local agitationResourceModifier = pageLairs.addRangeSetting("AgitationResourceModifier", 70, 50, 100, 10, "Agitation Resource Modifier");
    agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each agitation change. Higher percentage values result in greater resources, and therefore more powerful garrisoned troops and better loot.");

    local caravanReinforcementChance = pageCaravans.addRangeSetting("CaravanReinforcementChance", 100, 0, 100, 5, "Caravan Reinforcement Chance");
    caravanReinforcementChance.setDescription("Determines the percentage change for caravan troop count and composition reinforcement based on caravan wealth, and in special cases, cargo type.");

    local depopulateLairLootOnSpawn = pageLairs.addBooleanSetting("DepopulateLairLootOnSpawn", true, "Depopulate Lair Loot On Spawn");
    depopulateLairLootOnSpawn.setDescription("Determines whether Raids should depopulate newly spawned lairs of named loot. This is recommended to compensate for the additional named loot brought about by the introduction of agitation as a game mechanic.");

    local factionSpecificNamedLootChance = pageLairs.addRangeSetting("FactionSpecificNamedLootChance", 35, 0, 100, 5, "Faction Specific Named Loot Chance");
    factionSpecificNamedLootChance.setDescription("Determines the percentage chance for lairs to drop faction-specific named loot only, when conditions obtain.");

    local officialDocumentDropChance = pageCaravans.addRangeSetting("OfficialDocumentDropChance", 35, 10, 80, 5, "Official Document Drop Chance");
    officialDocumentDropChance.setDescription("Determines the chance for caravans to drop official documents on defeat. Official documents provide the only means for obtaining edicts.");

    local roamerScaleChance = pageLairs.addRangeSetting("RoamerScaleChance", 100, 0, 100, 5, "Roamer Scale Chance");
    roamerScaleChance.setDescription("Determines the percentage chance for hostile roaming and ambush parties spawning from lairs to scale in strength with respect to the originating lair's resource count. Does not affect beasts.");

    local roamerResourceModifier = pageLairs.addRangeSetting("RoamerResourceModifier", 70, 50, 100, 10, "Roamer Resource Modifier");
    roamerResourceModifier.setDescription("Controls how resource calculation is handled for roaming parties. Higher percentage values result in greater resources, and therefore more powerful roaming troops. Does nothing if roamer scale chance is set to zero.");

    local roamerScaleAgitationRequirement = pageLairs.addBooleanSetting("RoamerScaleAgitationRequirement", false, "Roamer Scale Agitation Requirement");
    roamerScaleAgitationRequirement.setDescription("Determines whether roamer scaling occurs for lairs with baseline agitation. Will result in stronger eligible roamer spawns on a game-wide basis.");

    local verboseLogging = pageGeneral.addBooleanSetting("VerboseLogging", true, "Verbose Logging"); // TODO: set this to false when done
    verboseLogging.setDescription("Enables verbose logging. Recommended for testing purposes only, as the volume of logged messages can make parsing the log more difficult for general use and debugging.");
});