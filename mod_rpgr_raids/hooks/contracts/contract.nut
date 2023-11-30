local Raids = ::RPGR_Raids;
::mods_hookBaseClass("contracts/contract", function( _object )
{
	Raids.Standard.wrap(_object, "start", function()
	{
		if (!("Destination" in this.m))
		{
			return;
		}

		if (this.m.Destination == null)
		{
			return;
		}

		if (!Raids.Lairs.isLocationTypeViable(this.m.Destination.getLocationType()))
		{
			return;
		}

		Raids.Lairs.setAgitation(this.m.Destination, Raids.Lairs.Procedures.Reset);
	});
});