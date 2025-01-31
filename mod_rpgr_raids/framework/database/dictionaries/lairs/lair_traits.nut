::Raids.Database.Lairs.Traits <-
{
	BanditExiles =
	{
		Chance = 20,
		Factions =
		[
			::Const.FactionType.Barbarians,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.BanditRaider,
				Num = ::Math.rand(4, 7)
			},
			{
				Type = ::Const.World.Spawn.Troops.BanditMarksman,
				Num = ::Math.rand(2, 5)
			}
		]
	},
	Cultists =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Bandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Cultist,
				Num = ::Math.rand(4, 15)
			}
		]
	},
	NobleDeserters =
	{
		Chance = 15,
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
				Num = ::Math.rand(4, 6)
			},
			{
				Type = ::Const.World.Spawn.Troops.Billman,
				Num = ::Math.rand(3, 5)
			},
			{
				Type = ::Const.World.Spawn.Troops.Greatsword,
				Num = ::Math.rand(1, 2)
			},
			{
				Type = ::Const.World.Spawn.Troops.Knight,
				Num = 1
			}
		]
	},
	SubjugatedGoblins =
	{
		Chance = 35,
		Factions =
		[
			::Const.FactionType.Orcs
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.GoblinAmbusher,
				Num = ::Math.rand(3, 6)
			},
			{
				Type = ::Const.World.Spawn.Troops.GoblinWolfrider,
				Num = ::Math.rand(2, 4)
			},
			{
				Type = ::Const.World.Spawn.Troops.GoblinOverseer,
				Num = 1
			}
		]
	},
	OrcAlliance =
	{
		Chance = 15,
		Factions =
		[
			::Const.FactionType.Goblins
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.OrcBerserker,
				Num = ::Math.rand(3, 6)
			},
			{
				Type = ::Const.World.Spawn.Troops.OrcWarrior,
				Num = ::Math.rand(2, 4)
			},
			{
				Type = ::Const.World.Spawn.Troops.OrcWarlord,
				Num = 1
			}
		]
	},
	HiredHands =
	{
		Chance = 20,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.BountyHunter,
				Num = ::Math.rand(2, 5)
			},
			{
				Type = ::Const.World.Spawn.Troops.BountyHunterRanged,
				Num = ::Math.rand(2, 4)
			},
			{
				Type = ::Const.World.Spawn.Troops.Mercenary,
				Num = ::Math.rand(2, 5)
			},
			{
				Type = ::Const.World.Spawn.Troops.MercenaryRanged,
				Num = ::Math.rand(2, 4)
			}
		]
	},
	NorthernExiles =
	{
		Chance = 15,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.BarbarianChampion,
				Num = ::Math.rand(1, 2)
			},
			{
				Type = ::Const.World.Spawn.Troops.BarbarianMarauder,
				Num = ::Math.rand(3, 8)
			},
		]
	},
	Necromancy =
	{
		Chance = 15,
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
				Num = ::Math.rand(1, 2)
			}
		]
	},
	SouthernExiles =
	{
		Chance = 20,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.NomadOutlaw,
				Num = ::Math.rand(3, 8)
			},
			{
				Type = ::Const.World.Spawn.Troops.NomadArcher,
				Num = ::Math.rand(2, 6)
			},
			{
				Type = ::Const.World.Spawn.Troops.DesertStalker,
				Num = 1
			},
			{
				Type = ::Const.World.Spawn.Troops.DesertDevil,
				Num = 1
			},
			{
				Type = ::Const.World.Spawn.Troops.Executioner,
				Num = 1
			}
		]
	},
	TamedDirewolves =
	{
		Chance = 15,
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
				Num = ::Math.rand(3, 6)
			}
		]
	},
	TamedHyenas =
	{
		Chance = 20,
		Factions =
		[
			::Const.FactionType.OrientalBandits,
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.HyenaHIGH,
				Num = ::Math.rand(3, 6)
			}
		]
	},
	TamedSerpents =
	{
		Chance = 20,
		Factions =
		[
			::Const.FactionType.OrientalBandits,
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Serpent,
				Num = ::Math.rand(2, 4)
			}
		]
	},
};