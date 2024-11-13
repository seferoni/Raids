::Raids.Database.Caravans.Common <-
{	// TODO: there needs to be a much more efficient way of sweeping out particular fields. make it a function
	CargoDescriptors =
	{
		Supplies = 1,
		Trade = 2,
		Assortment = 3,
		Unassorted = 4
	},
	CargoDistribution =
	{
		Supplies = 50,
		Trade = 100,
		Assortment = 20
	},
	NamedItemKeys =
	[
		"NamedArmors",
		"NamedWeapons",
		"NamedHelmets",
		"NamedShields"
	],
	WealthDescriptors =
	{
		Meager = 1,
		Moderate = 2,
		Plentiful = 3,
		Abundant = 4
	}
};