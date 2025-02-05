::Raids.Patcher.hookTree("scripts/contracts/contract", function( p )
{
	::Raids.Patcher.wrap(p, "start", function()
	{
		local candidate = ::Raids.Lairs.getCandidateByContract(this);

		if (candidate == null)
		{
			return;
		}

		::Raids.Lairs.resetLairBehaviour(_lairObject);
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

		::Raids.Lairs.resetLairBehaviour(_lairObject, true);
		::Raids.Lairs.updateProperties(candidate);
	});
});