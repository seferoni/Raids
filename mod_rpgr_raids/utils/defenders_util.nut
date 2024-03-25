local Raids = ::RPGR_Raids;
Raids.Lairs.Defenders <-
{
	Parameters =
	{
		ResourcesThresholdPrefactorFloor = 0.75,
		SpawnListLengthPrefactor = 0.25,
		TroopChoicesFloor = 1,
		TroopChoicesCeiling = 3
	}

	function addTroops( _troopTable, _lairObject )
	{
		foreach( troop in _troopTable.Troops )
		{
			for( local i = 0; i < troop.Num; i++ )
			{
				::Const.World.Common.addTroop(_lairObject, troop, false);
			}
		}

		_lairObject.updateStrength();
	}

	function createDefenders( _lairObject, _overrideAgitation = false )
	{
		::logInfo("createDefenders called for " + _lairObject.getName() + "with overrideAgitation " + _overrideAgitation)

		if (Raids.Standard.getFlag("Agitation", _lairObject) != Raids.Lairs.AgitationDescriptors.Relaxed && !_overrideAgitation)
		{
			return;
		}

		local candidate = this.getCandidate(_lairObject);
		this.updateProperties(_lairObject);
		this.addTroops(candidate, _lairObject);
	}

	function getCandidate( _lairObject )
	{
		# Prepare variables associated with lair properties.
		local spawnList = _lairObject.getDefenderSpawnList(),
		thresholdPrefactor = this.Parameters.ResourcesThresholdPrefactorFloor;

		# Get base resources scaled in a fashion similar to the vanilla algorithm.
		local resources = Raids.Standard.getFlag("BaseResources", _lairObject) * this.getResourcesPrefactor(_lairObject);

		# Retrieve all candidate templates from the spawnlist that are above 75% and below 100% of the scaled resources value.
		local candidates = spawnList.filter(@(_index, _party) _party.Cost <= resources && _party.Cost >= resources * thresholdPrefactor);

		if (candidates.len() == 0)
		{	# If no candidates can be found through the above heuristic, resort to a simpler algorithm.
			return this.getNaiveCandidate(_lairObject);
		}

		# Return a random candidate from this list.
		return candidates[::Math.rand(0, candidates.len() - 1)];
	}

	function getFactionName( _lairObject )
	{
		local typeID = _lairObject.getTypeID();

		foreach( overrideTable in Raids.Config.Defenders.Overrides )
		{
			if (overrideTable.TypeID == typeID)
			{
				return overrideTable.Faction;
			}
		}
		
		return this.getFactionNameFromType(this.getFactionType(_lairObject));
	}

	function getFactionNameFromType( _factionType )
	{
		foreach( factionName, factionEnum in ::Const.FactionType )
		{
			if (factionEnum == _factionType)
			{
				return factionName;
			}
		}
	}

	function getFactionType( _lairObject )
	{
		local factionType = ::World.FactionManager.getFaction(_lairObject.getFaction()).getType();
		return factionType;
	}

	function getTroopChoices()
	{
		return ::Math.rand(this.Parameters.TroopChoicesFloor, this.Parameters.TroopChoicesCeiling);
	}

	function getNaiveCandidate( _lairObject )
	{
		local spawnList = _lairObject.getDefenderSpawnList();

		# Cap template candidates to the bottom fourth of the total entries in the spawnlist.
		local ceiling = ::Math.floor((spawnList.len() - 1) * this.Parameters.SpawnListLengthPrefactor);

		# Return random party from within partitioned spawnlist.
		return spawnList[::Math.rand(0, ceiling)];
	}

	function getResourcesForReinforcement( _lairObject )
	{
		return ::Math.floor(_lairObject.getResources() * Raids.Standard.getPercentageSetting("AgitationResourceModifier"));
	}

	function getResourcesPrefactor( _lairObject )
	{
		local prefactor = 1.0;

		if (_lairObject.m.IsScalingDefenders)
		{
			prefactor *= ::Math.minf(Raids.Standard.getPercentageSetting("TimeScalePrefactorCeiling"), this.getTimeScalePrefactor());
		}

		if (!_lairObject.isAlliedWithPlayer())
		{
			prefactor *= ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()];
		}

		return prefactor;
	}

	function getTimeScalePrefactor()
	{	# These values are taken verbatim from the vanilla codebase.
		return (1.0 + ::World.getTime().Days * 0.0075);
	}

	function getViableTroopCandidates( _lairObject )
	{	// TODO: clean this up when done
		::logInfo("getting candidates for " + _lairObject.getName())
		local agitation = Raids.Standard.getFlag("Agitation", _lairObject);
		::logInfo("finding candidates with agitation " + agitation);

		local resources = this.getResourcesForReinforcement(_lairObject);
		::logInfo("got resources " + resources)

		local troopChoices = this.getTroopChoices();
		::logInfo("choices at " + troopChoices)

		local factionName = this.getFactionName(_lairObject);

		if (!(factionName in Raids.Config.Defenders.Troops))
		{
			return null;
		}

		local candidates = Raids.Config.Defenders.Troops[factionName].filter(function( _index, _troopTable )
		{
			::logInfo("looping over " + _troopTable.Type.Script)
			if (_troopTable.Cost > resources)
			{
				return false;
			}

			::logInfo("can afford " + _troopTable.Type.Script);

			if (!("Agitation" in _troopTable))
			{
				::logInfo("cant find agitation for " + _troopTable.Type.Script)
				return true;
			}

			if ("Floor" in _troopTable.Agitation && agitation < _troopTable.Agitation.Floor)
			{
				::logInfo("below floor for " + _troopTable.Type.Script)
				return false;
			}

			::logInfo("floor is okie dokie for " + _troopTable.Type.Script)

			if ("Ceiling" in _troopTable.Agitation && agitation > _troopTable.Agitation.Ceiling)
			{
				::logInfo("above ceiling for " + _troopTable.Type.Script)
				return false;
			}

			::logInfo("ceiling is okie dokie for " + _troopTable.Type.Script)

			return true;
		});

		this.resizeTroops(candidates, troopChoices);
		return candidates;
	}

	function reinforceDefenders( _lairObject )
	{
		if (Raids.Standard.getFlag("Agitation", _lairObject) == Raids.Lairs.AgitationDescriptors.Relaxed)
		{
			return;
		}

		local troopPool = this.getViableTroopCandidates(_lairObject);

		if (troopPool == null || troopPool.len() == 0)
		{
			::logInfo("ruh roh")
			return;
		}

		local selection = 
		{
			Troops = []
		},
		allocatedResources = ::Math.floor(this.getResourcesForReinforcement(_lairObject) / troopPool.len());

		foreach( troopTable in troopPool )
		{	// TODO: clean
			local newTroop = {};

			# Ensure at least one of the chosen troop type, if nominally affordable, can be added.
			local troopCount = ::Math.max(1, ::Math.floor(allocatedResources / troopTable.Cost));

			# Assign fields for the addTroops method to reference.
			newTroop.Type <- troopTable.Type;
			newTroop.Num <- ::Math.min(troopTable.MaxCount, troopCount);
			::logInfo("adding " + troopTable.Type.Script + " with count " + newTroop.Num);
			selection.Troops.push(newTroop);
		}

		this.addTroops(selection, _lairObject);
	}

	function resizeTroops( _troopArray, _newSize )
	{
		if (_troopArray.len() <= _newSize)
		{
			return;
		}

		# Place the cheapest, least consequential troops by the end of the array.
		_troopArray.sort(function( _firstValue, _secondValue )
		{
			if (_firstValue.Cost > _secondValue.Cost)
			{
				return -1;
			}

			return 1;
		});

		# Continue reducing troop array size until the desired size is reached.
		while( _troopArray.len() > _newSize )
		{
			_troopArray.pop();
		}
	}

	function updateProperties( _lairObject )
	{
		_lairObject.m.Troops = [];
		_lairObject.m.DefenderSpawnDay = ::World.getTime().Days;
	}
};
