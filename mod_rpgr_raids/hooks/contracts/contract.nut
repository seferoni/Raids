::Raids.Patcher.hookTree("contracts/contract", function( p )
{
	::Raids.Patcher.wrap(p, "start", function()
	{
		local candidate = ::Raids.Lairs.getCandidateByContract(this);

		if (candidate == null)
		{
			return;
		}

		::Raids.Standard.setFlag("DefenderSpawnsForbidden", true, candidate);
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

		::Raids.Standard.setFlag("DefenderSpawnsForbidden", false, candidate);
		::Raids.Lairs.updateProperties(candidate);
	});
});