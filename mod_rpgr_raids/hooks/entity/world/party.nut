::Raids.Patcher.hook("scripts/entity/world/party", function( p )
{
	::Raids.Patcher.wrap(p, "onCombatStarted", function()
	{
		if (!::Raids.Lairs.isPlayerInProximityTo(this.getTile(), 1))
		{
			return;
		}

		if (::Raids.Caravans.isPartyViable(this) && ::Raids.Caravans.isPartyInitialised(this))
		{
			::Raids.Caravans.updateOrigin(this);
		}

		::Raids.Lairs.updateCombatStatistics(true);
	});

	::Raids.Patcher.wrap(p, "onDropLootForPlayer", function( _lootTable )
	{
		if (!::Raids.Caravans.isPartyViable(this))
		{
			return;
		}

		if (!::Raids.Caravans.isPartyInitialised(this))
		{
			return;
		}

		if (!::Raids.Standard.getFlag("CaravanHasNamedItems", this))
		{
			return;
		}

		::Raids.Caravans.addNamedCargo(_lootTable, this);
		return [_lootTable];
	}, "overrideArguments");

	::Raids.Patcher.wrap(p, "getTooltip", function( _tooltipArray )
	{
		if (!::Raids.Caravans.isPartyViable(this))
		{
			return;
		}

		if (!::Raids.Caravans.isPartyInitialised(this))
		{
			return;
		}

		_tooltipArray.extend(::Raids.Caravans.getTooltipEntries(this));
		return _tooltipArray;
	});
});