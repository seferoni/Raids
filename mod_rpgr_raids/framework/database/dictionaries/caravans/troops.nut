::Raids.Database.Caravans.Troops <-
{
	Generic =
	{
		Conventional =
		[
			::Const.World.Spawn.Troops.CaravanGuard
		]
	},
	Mercenaries =
	{
		Conventional =
		[
			::Const.World.Spawn.Troops.Mercenary,
			::Const.World.Spawn.Troops.MercenaryLOW,
			::Const.World.Spawn.Troops.MercenaryRanged
		],
		Elite =
		[
			::Const.World.Spawn.Troops.HedgeKnight,
			::Const.World.Spawn.Troops.MasterArcher,
			::Const.World.Spawn.Troops.Swordmaster]
	},
	NobleHouse =
	{
		Conventional =
		[
			::Const.World.Spawn.Troops.Arbalester,
			::Const.World.Spawn.Troops.Billman,
			::Const.World.Spawn.Troops.Footman
		],
		Elite =
		[
			::Const.World.Spawn.Troops.Greatsword,
			::Const.World.Spawn.Troops.Knight,
			::Const.World.Spawn.Troops.Sergeant
		]
	},
	OrientalCityState =
	{
		Conventional =
		[
			::Const.World.Spawn.Troops.Conscript,
			::Const.World.Spawn.Troops.ConscriptPolearm,
			::Const.World.Spawn.Troops.Gunner
		],
		Elite =
		[
			::Const.World.Spawn.Troops.Assassin,
			::Const.World.Spawn.Troops.DesertDevil,
			::Const.World.Spawn.Troops.DesertStalker
		]
	}
};