::Raids.Database.Edicts.Common <-
{
	ConnateFactions =
	[
		::Const.FactionType.Bandits,
		::Const.FactionType.Barbarians,
		::Const.FactionType.OrientalBandits,
		::Const.FactionType.Zombies
	],
	Containers =
	[
		"EdictContainerA",
		"EdictContainerB",
		"EdictContainerC"
	],
	CycledEdicts =
	[
		"special.raids_edict_of_abundance_item",
		"special.raids_edict_of_agitation_item",
		"special.raids_edict_of_diminution_item",
		"special.raids_edict_of_opportunism_item"
	],
	LocationOverrides =
	[
		"location.undead_crypt"
	],
	ScalingModalities =
	{
		Static = 0,
		Agitation = 1,
		Resources = 2
	},
};