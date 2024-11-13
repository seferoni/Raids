::mods_hookBaseClass("contracts/contract", function( _object )
{
	::Raids.Standard.wrap(_object, "start", function()
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

	::Raids.Standard.wrap(_object, "onClear", function()
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

		# Named loot depopulation is not carried out here.
		::Raids.Standard.setFlag("DefenderSpawnsForbidden", false, candidate);
		::Raids.Lairs.updateProperties(candidate);
	});
});