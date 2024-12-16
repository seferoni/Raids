::Raids.Database.Edicts.WritingInstruments <-
{
	Excluded =
	[	// TODO: sugared ids have their uses, but we shouldn't be storing them in database imo, esp since we use ids everywhere else
		"Agitation"
	],
	SelectionModes =
	{
		Indiscriminate = 1,
		Agitation = 2,
		Selective = 3,
		Inverted = 4
	}
};