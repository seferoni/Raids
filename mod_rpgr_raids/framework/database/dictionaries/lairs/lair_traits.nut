::Raids.Database.Lairs.Traits <-
{
	AssassinsLeague =
	{
		Weight = 1,
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
		Weight = 3,
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
		Weight = 3,
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
	BeastTrophies =
	{
		Weight = 2,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians,
			::Const.FactionType.Goblins,
			::Const.FactionType.Orcs
		],
		AddedItems =
		[
			"scripts/items/misc/adrenaline_gland_item",
			"scripts/items/misc/ghoul_brain_item",
			"scripts/items/misc/ghoul_horn_item",
			"scripts/items/misc/ghoul_teeth_item",
			"scripts/items/misc/poison_gland_item",
			"scripts/items/misc/spider_silk_item",
			"scripts/items/misc/unhold_bones_item",
			"scripts/items/misc/unhold_heart_item",
			"scripts/items/misc/unhold_hide_item",
			"scripts/items/misc/werewolf_pelt_item",
		]
	},
	BeastTrophiesSouthern =
	{
		Weight = 2,
		Factions =
		[
			::Const.FactionType.OrientalBandits
		],
		AddedItems =
		[
			"scripts/items/misc/acidic_saliva_item",
			"scripts/items/misc/glistening_scales_item",
			"scripts/items/misc/hyena_fur_item",
			"scripts/items/misc/serpent_skin_item",
			"scripts/items/misc/sulfurous_rocks_item"
		]
	},
	BeastlyKennel =
	{
		Weight = 2,
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
		Weight = 1,
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
		Weight = 3,
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
		Weight = 2,
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
		Weight = 2,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.OrientalBandits
		],
		AddedGold = ::Math.rand(100, 200),
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
		Weight = 1,
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
		Weight = 2,
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
		Weight = 2,
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
		Weight = 1,
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
	Necromancy =
	{
		Weight = 1,
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
	NobleDeserters =
	{
		Weight = 2,
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
		Weight = 2,
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
		Weight = 2,
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
	OrcAlliance =
	{
		Weight = 1,
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
		Weight = 2,
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
		Weight = 2,
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
	RenegadeMilitia =
	{
		Weight = 2,
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
	RoguesCoterie =
	{
		Weight = 1,
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
	SlaveRevolt =
	{
		Weight = 2,
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
		Weight = 2,
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
	SubjugatedGoblins =
	{
		Weight = 2,
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
	SwordmastersKeep =
	{
		Weight = 1,
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
		Weight = 1,
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
		Weight = 1,
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
		Weight = 1,
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
		Weight = 3,
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
		Weight = 2,
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
		Weight = 1,
		Factions =
		[
			::Const.FactionType.Bandits,
			::Const.FactionType.Barbarians
		],
		AddedTroops =
		[
			{
				Type = ::Const.World.Spawn.Troops.Hexe,
				Num = ::Math.rand(1, 3)
			}
		]
	}
};