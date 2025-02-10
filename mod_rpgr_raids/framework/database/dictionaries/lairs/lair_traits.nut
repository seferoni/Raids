::Raids.Database.Lairs.Traits <-
{
	AssassinsLeague =
	{
		Chance = 5,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Assassin,
				Num = ::Math.rand(3, 8)
			}
		]
	},
	Avaricious =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits,
			::Const.FactionType.Orcs,
			::Const.FactionType.Goblins
		],
		AddedGold = ::Math.rand(200, 500)
	},
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
	BeastlyKennel =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Barbarians,
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Wardog,
				Num = ::Math.rand(6, 10)
			}
		]
	},
	Cultists =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Cultist,
				Num = ::Math.rand(4, 15)
			}
		]
	},
	EnthralledMasses =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Barbarians
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.BarbarianThrall,
				Num = ::Math.rand(6, 20)
			}
		]
	},
	HeroesGraveyard =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Undead,
			::Const.FactionType.Zombies
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.ZombieKnight,
				Num = ::Math.rand(3, 8)
			}
		]
	},
	HiredHands =
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
	HolyCongregation =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Undead,
			::Const.FactionType.Zombies
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.SkeletonPriest,
				Num = ::Math.rand(1, 3)
			}
		]
	},
	Marksmen =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Bandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.BanditMarksman,
				Num = ::Math.rand(5, 8)
			}
		]
	},
	MarksmenSouthern =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.NomadArcher,
				Num = ::Math.rand(5, 8)
			}
		]
	},
	MercenaryKnights =
	{
		Chance = 5,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.HedgeKnight,
				Num = ::Math.rand(1, 3)
			}
		]
	},
	NobleDeserters =
	{
		Chance = 15,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Footman,
				Num = ::Math.rand(6, 8)
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
				Num = ::Math.rand(1, 2)
			}
		]
	},
	NobleDesertersSouthern =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Conscript,
				Num = ::Math.rand(6, 12)
			},
			{
				Type = ::Const.World.Spawn.Troops.ConscriptPolearm,
				Num = ::Math.rand(4, 6)
			},
			{
				Type = ::Const.World.Spawn.Troops.Gunner,
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
	PeasantRevolt =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Bandits,
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Peasant,
				Num = ::Math.rand(10, 25)
			}
		]
	},
	PeasantRevoltSouthern =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.SouthernPeasant,
				Num = ::Math.rand(10, 25)
			}
		]
	},
	RoguesCoterie =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Bandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.MasterArcher,
				Num = ::Math.rand(2, 5)
			}
		]
	},
	RenegadeMilitia =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Bandits,
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Militia,
				Num = ::Math.rand(8, 16)
			},
			{
				Type = ::Const.World.Spawn.Troops.MilitiaVeteran,
				Num = ::Math.rand(6, 12)
			},
			{
				Type = ::Const.World.Spawn.Troops.MilitiaRanged,
				Num = ::Math.rand(5, 8)
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
	SlaveRevolt =
	{
		Chance = 15,
		Factions =
		[
			::Const.FactionType.OrientalBandits,
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Slave,
				Num = ::Math.rand(10, 25)
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
			}
		]
	},
	SwordmastersKeep =
	{
		Chance = 5,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Swordmaster,
				Num = ::Math.rand(1, 5)
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
				Num = ::Math.rand(3, 7)
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
				Num = ::Math.rand(3, 7)
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
	UndeadVanguard =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Undead,
			::Const.FactionType.Zombies
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.SkeletonHeavy,
				Num = ::Math.rand(6, 10)
			},
			{
				Type = ::Const.World.Spawn.Troops.SkeletonHeavyPolearm,
				Num = ::Math.rand(4, 6)
			}
		]
	},
	VampiricBrood =
	{
		Chance = 10,
		Factions =
		[
			::Const.FactionType.Undead,
			::Const.FactionType.Zombies
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Vampire,
				Num = ::Math.rand(3, 8)
			}
		]
	},
	WitchesCoven =
	{
		Chance = 5,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Hexe,
				Num = ::Math.rand(1, 4)
			}
		]
	}
};