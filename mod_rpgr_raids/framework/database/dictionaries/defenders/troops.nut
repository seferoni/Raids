::Raids.Database.Defenders.Troops <-
{
	Bandits =
	[
		{
			Type = ::Const.World.Spawn.Troops.BanditThug,
			Tag = ::Raids.Lairs.getField("TroopTags").Fodder,
			Cost = 15,
			MaxCount = 9,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BanditRaider,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 35,
			MaxCount = 7,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BanditMarksman,
			Tag = ::Raids.Lairs.getField("TroopTags").Ranged,
			Cost = 45,
			MaxCount = 6,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BanditLeader,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 85,
			MaxCount = 1
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.MasterArcher,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 100,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.HedgeKnight,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
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
			Tag = ::Raids.Lairs.getField("TroopTags").Fodder,
			Cost = 35,
			MaxCount = 8,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.BarbarianMarauder,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 45,
			MaxCount = 6
		},
		{
			Type = ::Const.World.Spawn.Troops.BarbarianChampion,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
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
			Tag = ::Raids.Lairs.getField("TroopTags").Fodder,
			Cost = 25,
			MaxCount = 7,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.NomadOutlaw,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 35,
			MaxCount = 8,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.NomadArcher,
			Tag = ::Raids.Lairs.getField("TroopTags").Ranged,
			Cost = 45,
			MaxCount = 6
		},
		{
			Type = ::Const.World.Spawn.Troops.NomadLeader,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 85,
			MaxCount = 2
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.DesertStalker,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 105,
			MaxCount = 1,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.DesertDevil,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 125,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Executioner,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
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
			Tag = ::Raids.Lairs.getField("TroopTags").Fodder,
			Cost = 15,
			MaxCount = 9,
			Agitation =
			{
				Ceiling = 2
			}
		}
		{
			Type = ::Const.World.Spawn.Troops.ZombieYeoman,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 25,
			MaxCount = 8,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Necromancer,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 55,
			MaxCount = 1,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Ghost,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 65,
			MaxCount = 3,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.ZombieKnight,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
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
			Tag = ::Raids.Lairs.getField("TroopTags").Fodder,
			Cost = 35,
			MaxCount = 7,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.OrcBerserker,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 50,
			MaxCount = 5,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.OrcWarrior,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 65,
			MaxCount = 5,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.OrcWarlord,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
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
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 30,
			MaxCount = 5,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinAmbusher,
			Tag = ::Raids.Lairs.getField("TroopTags").Ranged,
			Cost = 45,
			MaxCount = 6
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinWolfrider,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 60,
			MaxCount = 4,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinShaman,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 100,
			MaxCount = 1,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.GoblinOverseer,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
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
			Type = ::Const.World.Spawn.Troops.SkeletonLight,
			Tag = ::Raids.Lairs.getField("TroopTags").Fodder,
			Cost = 15,
			MaxCount = 9,
			Agitation =
			{
				Ceiling = 2
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonMedium,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 30,
			MaxCount = 6,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonMediumPolearm,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 35,
			MaxCount = 4,
			Agitation =
			{
				Ceiling = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonHeavy,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 50,
			MaxCount = 5,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonHeavyPolearm,
			Tag = ::Raids.Lairs.getField("TroopTags").Melee,
			Cost = 55,
			MaxCount = 4,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.Vampire,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 65,
			MaxCount = 3,
			Agitation =
			{
				Floor = 3
			}
		},
		{
			Type = ::Const.World.Spawn.Troops.SkeletonPriest,
			Tag = ::Raids.Lairs.getField("TroopTags").Unique,
			Cost = 110,
			MaxCount = 1,
			Agitation =
			{
				Floor = 4
			}
		}
	]
};