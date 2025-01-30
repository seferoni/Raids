::Raids.Database.Lairs.Traits <-
{	// TODO: need individual chances for each trait to proc, and need to shuffle the collected array of traits per fetch. most lairs should not have traits!
	BanditExiles =
	{
		Factions =
		[
			::Const.FactionType.Barbarians,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.BanditRaider,
				Count = ::Math.rand(4, 7)
			},
			{
				Type = ::Const.World.Spawn.Troops.BanditMarksman,
				Count = ::Math.rand(2, 5)
			}
		]
	},
	Bladesmen =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Goblins,
			::Const.FactionType.OrientalBandits
		],
		TroopPreferences = ::Raids.Lairs.getField("TroopTags").Melee
	},
	Cultists =
	{
		Factions =
		[
			::Const.FactionType.Bandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Cultist,
				Count = ::Math.rand(4, 15)
			}
		]
	},
	NobleDeserters =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Footman,
				Count = ::Math.rand(4, 6)
			},
			{
				Type = ::Const.World.Spawn.Troops.Billman,
				Count = ::Math.rand(3, 5)
			},
			{
				Type = ::Const.World.Spawn.Troops.Greatsword,
				Count = ::Math.rand(1, 2)
			},
			{
				Type = ::Const.World.Spawn.Troops.Knight,
				Count = 1
			}
		]
	},
	SubjugatedGoblins =
	{
		Factions =
		[
			::Const.FactionType.Orcs
		],
		AddedTroops =
		[

		]
	},
	OrcAlliance =
	{
		Factions =
		[
			::Const.FactionType.Goblins
		],
		AddedTroops =
		[

		]
	}
	Marksmen =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Goblins,
			::Const.FactionType.OrientalBandits
		],
		TroopPreferences = ::Raids.Lairs.getField("TroopTags").Ranged
	},
	HiredHands =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			// TODO: add both bounty hunters and mercs
		]
	},
	NorthernExiles =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.BarbarianChampion,
				Count = ::Math.rand(1, 2)
			},
			{
				Type = ::Const.World.Spawn.Troops.BarbarianMarauder,
				Count = ::Math.rand(3, 8)
			},
		]
	},
	Necromancy =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Necromancer,
				Count = ::Math.rand(1, 2)
			}
		]
	},
	Swarming =
	{
		TroopPreferences = ::Raids.Lairs.getField("TroopTags").Fodder
	},
	Mighty =
	{
		TroopPreferences = ::Raids.Lairs.getField("TroopTags").Unique
	},
	SouthernExiles =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.DesertStalker,
				Count = 1
			},
			{
				Type = ::Const.World.Spawn.Troops.DesertDevil,
				Count = 1
			},
			{
				Type = ::Const.World.Spawn.Troops.Executioner,
				Count = 1
			},
			{
				Type = ::Const.World.Spawn.Troops.NomadOutlaw,
				Count = ::Math.rand(3, 8)
			},
			{
				Type = ::Const.World.Spawn.Troops.NomadArcher,
				Count = ::Math.rand(2, 6)
			}
		]
	},
	TamedDirewolves =
	{
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians,
			::Const.FactionType.Goblins,
			::Const.FactionType.Orcs
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Direwolf,
				Count = ::Math.rand(3, 6)
			}
		]
	},
	TamedHyenas =
	{
		Factions =
		[
			::Const.FactionType.OrientalBandits,
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.HyenaHIGH,
				Count = ::Math.rand(3, 6)
			}
		]
	},
	TamedSerpents =
	{
		Factions =
		[
			::Const.FactionType.OrientalBandits,
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Serpent,
				Count = ::Math.rand(2, 4)
			}
		]
	},
};