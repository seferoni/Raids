local Raids = ::RPGR_Raids;
::mods_hookBaseClass("contracts/contract", function( _object )
{
	Raids.Standard.wrap(_object, "start", function()
	{
		local candidate = Raids.Lairs.getCandidateByContract(this);

		if (candidate == null)
		{
			return;
		}

		Raids.Standard.setFlag("DefenderSpawnsForbidden", true, candidate);
		Raids.Lairs.setAgitation(candidate, Raids.Lairs.Procedures.Reset);
	});

	Raids.Standard.wrap(_object, "onClear", function()
	{
		if (!this.isActive())
		{
			return;
		}

		local candidate = Raids.Lairs.getCandidateByContract(this);

		if (candidate == null)
		{
			return;
		}

		Raids.Standard.setFlag("DefenderSpawnsForbidden", false, candidate);
	});
});