::mods_hookBaseClass("factions/faction", function( _object )
{
	::Raids.Standard.wrap(_object, "spawnEntity", function( _tile, _name, _uniqueName, _template, _resources )
	{
		if (::Math.rand(1, 100) > ::Raids.Standard.getSetting("RoamerScaleChance"))
		{
			return;
		}

		if (!::Raids.Lairs.isFactionViable(this))
		{
			return;
		}

		if (_template == null)
		{
			return;
		}

		local lair = ::Raids.Lairs.getCandidateAtPosition(_tile.Coords);

		if (lair == null)
		{
			return;
		}

		if (::Raids.Standard.getSetting("RoamerScaleAgitationRequirement") && ::Raids.Standard.getFlag("Agitation", lair) == ::Raids.Lairs.AgitationDescriptors.Relaxed)
		{
			return;
		}

		return [_tile, _name, _uniqueName, _template, _resources + ::Raids.Lairs.getPartyResources(lair)];
	}, "overrideArguments");
});