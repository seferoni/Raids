local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/location", function( _object )
{
	Raids.Standard.wrap(_object, "createDefenders", function()
	{
		if (!Raids.Lairs.isLocationViable(this, false))
		{
			return;
		}

		if (Raids.Standard.getFlag("DefenderSpawnsForbidden", this))
		{
			return Raids.Internal.TERMINATE;
		}

		Raids.Lairs.Defenders.createDefenders(this);
		return Raids.Internal.TERMINATE;
	}, "overrideMethod");

	Raids.Standard.wrap(_object, "dropTreasure", function( _num, _items, _lootTable )
	{
		if (!Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		local count = Raids.Lairs.getTreasureCount(this),
		offset = Raids.Edicts.getTreasureOffset(this);
		return [count + offset, _items, _lootTable];
	}, "overrideArguments");

	Raids.Standard.wrap(_object, "dropMoney", function( _num, _lootTable )
	{
		if (!Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		local count = Raids.Lairs.getMoneyCount(this);
		return [count, _lootTable];
	}, "overrideArguments");

	Raids.Standard.wrap(_object, "getTooltip", function()
	{
		if (!Raids.Lairs.isLocationViable(this, true, true))
		{
			return;
		}

		Raids.Lairs.updateAgitation(this);
		Raids.Edicts.updateEdicts(this);
	}, "overrideArguments");

	Raids.Standard.wrap(_object, "getTooltip", function( _tooltipArray )
	{
		if (!Raids.Lairs.isLocationViable(this, true, true))
		{
			return;
		}

		_tooltipArray.extend(Raids.Lairs.getTooltipEntries(this));
		_tooltipArray.extend(Raids.Edicts[format("get%sEntries", Raids.Edicts.isLairViable(this) ? "Tooltip" : "Nonviable")](this));
		return _tooltipArray;
	});

	Raids.Standard.wrap(_object, "onCombatStarted", function()
	{
		if (!Raids.Lairs.isLocationViable(this, true, true))
		{
			return;
		}

		Raids.Lairs.updateCombatStatistics(false);
	});

	Raids.Standard.wrap(_object, "onDropLootForPlayer", function( _lootTable )
	{
		if (!Raids.Lairs.isLocationViable(this, true, false, false))
		{
			return;
		}

		local locationType = this.getLocationType();

		if (!Raids.Lairs.isLocationTypeViable(locationType) && !Raids.Lairs.isLocationTypePassive(locationType))
		{
			return;
		}

		Raids.Lairs.addLoot(_lootTable, this);
		return [_lootTable];
	}, "overrideArguments");

	Raids.Standard.wrap(_object, "onSpawned", function()
	{
		if (!Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		Raids.Lairs.initialiseLairParameters(this);

		if (Raids.Standard.getSetting("DepopulateLairLootOnSpawn"))
		{
			Raids.Lairs.depopulateNamedLoot(this, Raids.Lairs.Parameters.NamedItemRemovalChanceOnSpawn);
		}
	});

	Raids.Standard.wrap(_object, "setLastSpawnTimeToNow", function()
	{
		if (!Raids.Lairs.isLocationViable(this))
		{
			return;
		}

		local spawnTime = this.getLastSpawnTime(),
		offset = Raids.Lairs.getSpawnTimeOffset(this);
		this.m.LastSpawnTime = ::Math.max(0.0, spawnTime + offset);
	});
});