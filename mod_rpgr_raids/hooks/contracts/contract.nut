::Raids.Patcher.hookTree("scripts/contracts/contract", function( p )
{
	::Raids.Patcher.wrap(p, "start", function()
	{
		local candidate = ::Raids.Lairs.getCandidateByContract(this);

		if (candidate == null)
		{
			return;
		}

		// TODO: need to forbid trait and defender behaviour here.
		::Raids.Lairs.setAgitation(candidate, ::Raids.Lairs.Procedures.Reset);
		::Raids.Edicts.clearEdicts(candidate);
	});

	::Raids.Patcher.wrap(p, "onClear", function()
	{
		if (!this.isActive())
		{
			return;
		}

		local candidate = ::Raids.Lairs.getCandidateByContract(this);

		if (candidate == null)
		{
			return;
		}

		// TODO: need to enable trait and defender behaviour here.
		::Raids.Lairs.updateProperties(candidate);
	});
});