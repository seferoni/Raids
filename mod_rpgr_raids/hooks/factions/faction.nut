::Raids.Patcher.hookTree("scripts/factions/faction", function( p )
{
	::Raids.Patcher.wrap(p, "spawnEntity", function( _tile, _name, _uniqueName, _template, _resources, _minibossify = 0 )
	{
		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("RoamerScaleChance"))
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

		if (::Raids.Standard.getParameter("RoamerScaleAgitationRequirement") && ::Raids.Lairs.getAgitation(lair) == ::Raids.Lairs.getField("AgitationDescriptors").Relaxed)
		{
			return;
		}

		return [_tile, _name, _uniqueName, _template, _resources + ::Raids.Lairs.getPartyResources(lair), _minibossify];
	}, "overrideArguments");
});