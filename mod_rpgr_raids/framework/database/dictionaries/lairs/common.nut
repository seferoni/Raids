::Raids.Database.Lairs.Common <-
{
	AgitationDescriptors =
	{
		Relaxed = 1,
		Cautious = 2,
		Vigilant = 3,
		Militant = 4
	},
	Factions =
	[
		::Const.FactionType.Bandits,
		::Const.FactionType.Barbarians,
		::Const.FactionType.Goblins,
		::Const.FactionType.Orcs,
		::Const.FactionType.OrientalBandits,
		::Const.FactionType.Undead,
		::Const.FactionType.Zombies
	],
	Overrides =
	[
		{
			TypeID = "location.undead_crypt",
			Faction = ::Const.FactionType.Zombies
		}
	]
};