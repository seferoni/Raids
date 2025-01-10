::Raids.Database.Defenders.Troops <-
{
	Bandits =
	[
		{
			Type = ::Const.World.Spawn.Troops.BanditThug,
			Cost = 15,
			MaxCount = 9,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BanditRaider,
			Cost = 35,
			MaxCount = 7,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BanditMarksman,
			Cost = 45,
			MaxCount = 6,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BanditLeader,
			Cost = 85,
			MaxCount = 1
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.MasterArcher,
			Cost = 100,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.HedgeKnight,
			Cost = 100,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		},
	],
	Barbarians =
	[
		{
			Type = ::Const.World.Spawn.Troops.BarbarianThrall,
			Cost = 35,
			MaxCount = 8,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BarbarianMarauder,
			Cost = 45,
			MaxCount = 6
		},
		{
			Type = ::Const.World.Spawn.Troops.BarbarianChampion,
			Cost = 75,
			MaxCount = 5,
			Agitation =
			{
				Floor = 3
			}
		}
	],
	OrientalBandits =
	[
		{
			Type = ::Const.World.Spawn.Troops.NomadCutthroat,
			Cost = 25,
			MaxCount = 7,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.NomadOutlaw,
			Cost = 35,
			MaxCount = 8,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.NomadArcher,
			Cost = 45,
			MaxCount = 6
		},
		{
			Type = ::Const.World.Spawn.Troops.NomadLeader,
			Cost = 85,
			MaxCount = 2
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.DesertStalker,
			Cost = 105,
			MaxCount = 1,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.DesertDevil,
			Cost = 125,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Executioner,
			Cost = 140,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		}
	],
	Zombies =
	[
		{
			Type = ::Const.World.Spawn.Troops.Zombie,
			Cost = 15,
			MaxCount = 9,
			Agitation =
			{
				Ceiling = 2
			}
		}
		{
			Type = ::Const.World.Spawn.Troops.ZombieYeoman,
			Cost = 25,
			MaxCount = 8,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Necromancer,
			Cost = 55,
			MaxCount = 1,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Ghost,
			Cost = 65,
			MaxCount = 3,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.ZombieKnight,
			Cost = 50,
			MaxCount = 6,
			Agitation =
			{
				Floor = 3
			}
		}
	],
	Orcs =
	[
		{
			Type = ::Const.World.Spawn.Troops.OrcYoung,
			Cost = 35,
			MaxCount = 7,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.OrcBerserker,
			Cost = 50,
			MaxCount = 5,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.OrcWarrior,
			Cost = 65,
			MaxCount = 5,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.OrcWarlord,
			Cost = 120,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		}
	],
	Goblins =
	[
		{
			Type = ::Const.World.Spawn.Troops.GoblinSkirmisher,
			Cost = 30,
			MaxCount = 5,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinAmbusher,
			Cost = 45,
			MaxCount = 6
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinWolfrider,
			Cost = 60,
			MaxCount = 4,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinShaman,
			Cost = 100,
			MaxCount = 1,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinOverseer,
			Cost = 100,
			MaxCount = 1,
			Agitation =
			{
				Floor = 3
			}
		}
	],
	Undead =
	[
		{
			Type = ::Const.World.Spawn.Troops.SkeletonMedium,
			Cost = 30,
			MaxCount = 6,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonMediumPolearm,
			Cost = 35,
			MaxCount = 4,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonHeavy,
			Cost = 50,
			MaxCount = 5,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonHeavyPolearm,
			Cost = 55,
			MaxCount = 4,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Vampire,
			Cost = 65,
			MaxCount = 3,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonPriest,
			Cost = 110,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		}
	]
};