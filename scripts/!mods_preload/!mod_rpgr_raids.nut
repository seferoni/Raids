::RPGR_Raids <-
{
	ID = "mod_rpgr_raids",
	Name = "RPG Rebalance - Raids",
	Version = "3.1.0",
	Internal =
	{
		TERMINATE = "__end"
	},
	Defaults =
	{
		AgitationIncrementChance = 100,
		AgitationResourceModifier = 65,
		CaravanReinforcementChance = 100,
		DepopulateLairLootOnSpawn = true,
		FactionSpecificNamedLootChance = 35,
		OfficialDocumentDropChance = 50,
		RoamerScaleChance = 100,
		RoamerResourceModifier = 70,
		RoamerScaleAgitationRequirement = true,
		ShowNamedLootEntry = true,
		TimeScalePrefactorCeiling = 150
	}
}

local Raids = ::RPGR_Raids;
Raids.Internal.MSUFound <- "MSU" in ::getroottable();
::include("mod_rpgr_raids/libraries/standard_library.nut");

if (!Raids.Internal.MSUFound)
{
	Raids.Version = Raids.Standard.parseSemVer(Raids.Version);
}

::mods_registerMod(Raids.ID, Raids.Version, Raids.Name);
::mods_queue(Raids.ID, ">mod_msu", function()
{
	if (!Raids.Internal.MSUFound)
	{
		return;
	}

	Raids.Mod <- ::MSU.Class.Mod(Raids.ID, Raids.Version, Raids.Name);

	local pageLairs = Raids.Mod.ModSettings.addPage("Lairs"),
	pageCaravans = Raids.Mod.ModSettings.addPage("Caravans"),
	Defaults = Raids.Defaults;

	# Assign lair settings.
	local depopulateLairLootOnSpawn = pageLairs.addBooleanSetting("DepopulateLairLootOnSpawn", Defaults.DepopulateLairLootOnSpawn, "Depopulate Lair Loot On Spawn");
	depopulateLairLootOnSpawn.setDescription("Determines whether Raids should depopulate newly spawned lairs of named loot.");

	local showNamedLootEntry = pageLairs.addBooleanSetting("ShowNamedLootEntry", Defaults.ShowNamedLootEntry, "Show Named Loot Count On Tooltip");
	showNamedLootEntry.setDescription("Determines whether lairs display the number of currently retained named items on their tooltips.");

	local roamerScaleAgitationRequirement = pageLairs.addBooleanSetting("RoamerScaleAgitationRequirement", Defaults.RoamerScaleAgitationRequirement, "Roamer Scale Agitation Requirement");
	roamerScaleAgitationRequirement.setDescription("Determines whether roamer scaling occurs only for lairs above baseline Agitation. If set to false, this will result in stronger eligible roamer spawns on a game-wide basis.");

	local agitationIncrementChance = pageLairs.addRangeSetting("AgitationIncrementChance", Defaults.AgitationIncrementChance, 0, 100, 1, "Agitation Increment Chance");
	agitationIncrementChance.setDescription("Determines the chance for a lair's Agitation value to increase upon engagement with a roaming party, if within proximity.");

	local agitationResourceModifier = pageLairs.addRangeSetting("AgitationResourceModifier", Defaults.AgitationResourceModifier, 50, 150, 10, "Agitation Resource Modifier");
	agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each Agitation update. Higher percentage values result in greater resources, and therefore more powerful garrisoned troops and more loot.");

	local roamerScaleChance = pageLairs.addRangeSetting("RoamerScaleChance", Defaults.RoamerScaleChance, 0, 100, 5, "Roamer Scale Chance");
	roamerScaleChance.setDescription("Determines the percentage chance for hostile roaming and ambush parties spawning from lairs to scale in strength with respect to the originating lair's resource count. Does not affect beasts.");

	local roamerResourceModifier = pageLairs.addRangeSetting("RoamerResourceModifier", Defaults.RoamerResourceModifier, 50, 100, 10, "Roamer Resource Modifier");
	roamerResourceModifier.setDescription("Controls how resource calculation is handled for roaming parties. Higher percentage values result in greater resources, and therefore more powerful roaming troops. Does nothing if roamer scale chance is set to zero.");

	local timeScalePrefactorCeiling = pageLairs.addRangeSetting("TimeScalePrefactorCeiling", Defaults.TimeScalePrefactorCeiling, 100, 300, 10, "Time Scaling Modifier");
	timeScalePrefactorCeiling.setDescription("Determines the maximum value beyond which the further passage of time no longer affects location strength. In the base game, this is at 300. This has a very significant effect on location difficulty.");

	# Assign caravan settings.
	local caravanReinforcementChance = pageCaravans.addRangeSetting("CaravanReinforcementChance", Defaults.CaravanReinforcementChance, 0, 100, 5, "Caravan Reinforcement Chance");
	caravanReinforcementChance.setDescription("Determines the percentage change for caravan troop count and composition reinforcement based on caravan wealth, and in special cases, cargo type.");

	local factionSpecificNamedLootChance = pageLairs.addRangeSetting("FactionSpecificNamedLootChance", Defaults.FactionSpecificNamedLootChance, 0, 100, 5, "Faction Specific Named Loot Chance");
	factionSpecificNamedLootChance.setDescription("Determines the percentage chance for lairs to drop faction-specific named loot only, when conditions obtain.");

	local officialDocumentDropChance = pageCaravans.addRangeSetting("OfficialDocumentDropChance", Defaults.OfficialDocumentDropChance, 10, 65, 5, "Official Document Drop Chance");
	officialDocumentDropChance.setDescription("Determines the chance for caravans to drop official documents on defeat. Official documents provide the only means for obtaining Edicts. This does not affect the drop rate for lairs.");

});