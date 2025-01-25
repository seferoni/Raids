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
		"Abundance",
		"Agitation",
		"Diminution",
		"Opportunism"
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