::Raids.Patcher.hook("scripts/entity/world/location", function( p )
{
	::Raids.Patcher.wrap(p, "createDefenders", function()
	{
		if (!::Raids.Lairs.isLocationViable(this, false))
		{
			return;
		}

		if (::Raids.Lairs.Defenders.getReinforcementForbiddenState(this))
		{
			return ::Raids.Internal.TERMINATE;
		}

		if (!::Raids.Lairs.Traits.getTraitProperties(this).TraitKey)
		{
			::Raids.Lairs.Traits.initialiseLairTrait(this);
		}

		::logInfo("creating Defenders for " + this.getName())
		::Raids.Lairs.Defenders.createDefenders(this);
		::logInfo("generated " + this.getTroops().len() + " troops")
		return ::Raids.Internal.TERMINATE;
	}, "overrideMethod");

	::Raids.Patcher.wrap(p, "dropTreasure", function( _num, _items, _lootTable )
	{
		if (!::Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		local count = ::Raids.Lairs.getTreasureCount(this);
		local offset = ::Raids.Edicts.getTreasureOffset(this);
		return [count + offset, _items, _lootTable]; // TODO: need to inject items into _lootTable by lair trait
	}, "overrideArguments");

	::Raids.Patcher.wrap(p, "dropMoney", function( _num, _lootTable )
	{
		if (!::Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		local count = ::Raids.Lairs.getMoneyCount(this);
		return [count, _lootTable];
	}, "overrideArguments");

	::Raids.Patcher.wrap(p, "getTooltip", function()
	{
		if (!::Raids.Lairs.isLocationViable(this, true, true))
		{
			return;
		}

		::Raids.Lairs.updateAgitation(this);
		::Raids.Edicts.updateEdicts(this);
	}, "overrideArguments");

	::Raids.Patcher.wrap(p, "getTooltip", function( _tooltipArray )
	{
		if (!::Raids.Lairs.isLocationViable(this, true, true))
		{
			return;
		}

		_tooltipArray.extend(::Raids.Lairs.getTooltipEntries(this));
		_tooltipArray.extend(::Raids.Edicts[format("get%sEntries", ::Raids.Edicts.isLairViable(this) ? "Tooltip" : "Nonviable")](this));
		return _tooltipArray;
	});

	::Raids.Patcher.wrap(p, "onCombatStarted", function()
	{
		if (!::Raids.Lairs.isLocationViable(this, true, true))
		{
			return;
		}

		::Raids.Standard.setLastFoeWasPartyStatistic(false);
	});

	::Raids.Patcher.wrap(p, "onDropLootForPlayer", function( _lootTable )
	{
		if (!::Raids.Lairs.isLocationViable(this, true, false, false))
		{
			return;
		}

		local locationType = this.getLocationType();

		if (!::Raids.Lairs.isLocationTypeViable(locationType) && !::Raids.Lairs.isLocationTypePassive(locationType))
		{
			return;
		}

		::Raids.Lairs.addLoot(_lootTable, this);
		return [_lootTable];
	}, "overrideArguments");

	::Raids.Patcher.wrap(p, "onSpawned", function()
	{
		if (!::Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		::Raids.Lairs.initialiseLairParameters(this);

		if (::Raids.Standard.getParameter("DepopulateLairLootOnSpawn"))
		{
			::Raids.Lairs.depopulateNamedLoot(this, ::Raids.Lairs.Parameters.NamedItemRemovalChanceOnSpawn);
		}
	});

	::Raids.Patcher.wrap(p, "setLastSpawnTimeToNow", function()
	{
		if (!::Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		local spawnTime = this.getLastSpawnTime();
		local offset = ::Raids.Lairs.getSpawnTimeOffset(this);
		this.m.LastSpawnTime = ::Math.max(0.0, spawnTime + offset);
	});
});