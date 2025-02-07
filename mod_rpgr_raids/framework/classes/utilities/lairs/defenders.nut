::Raids.Lairs.Defenders <-
{
	Parameters =
	{
		ResourcesThresholdPrefactorFloor = 0.75,
		SpawnListLengthPrefactor = 0.25,
		TroopChoicesFloor = 1,
		TroopChoicesCeiling = 3
	}

	function addTroops( _troopTable, _lairObject )
	{	// TODO: Very oddly structured. There ought be a better way.
		foreach( troop in _troopTable.Troops )
		{
			for( local i = 0; i < troop.Num; i++ )
			{
				::Const.World.Common.addTroop(_lairObject, troop, false);
			}
		}

		_lairObject.updateStrength();
	}

	function createDefenders( _lairObject, _overrideAgitationRequirement = false )
	{
		if (!this.isLairAgitated(_lairObject) && !_overrideAgitationRequirement)
		{
			return;
		}

		local candidate = this.getCandidate(_lairObject);
		this.updateProperties(_lairObject);
		this.addTroops(candidate, _lairObject);
	}

	function setDefenderReinforcementState( _boolean, _lairObject )
	{	// TODO: this does need to be forbidden
		::Raids.Standard.setFlag("DefenderReinforcementState", _boolean, candidate);
	}

	function getCandidate( _lairObject )
	{
		local spawnList = _lairObject.getDefenderSpawnList();
		local thresholdPrefactor = this.Parameters.ResourcesThresholdPrefactorFloor;
		local resources = ::Raids.Standard.getFlag("BaseResources", _lairObject) * this.getResourcesPrefactor(_lairObject);
		local candidates = spawnList.filter(@(_index, _party) _party.Cost <= resources && _party.Cost >= resources * thresholdPrefactor);

		if (candidates.len() == 0)
		{	# If no candidates can be found through the above heuristic, resort to a simpler algorithm.
			return this.getNaiveCandidate(_lairObject);
		}

		return candidates[::Math.rand(0, candidates.len() - 1)];
	}

	function getDefenderReinforcementState( _lairObject )
	{
		return ::Raids.Standard.getFlag("DefenderReinforcementState", _lairObject);
	}

	function getField( _fieldName )
	{
		return ::Raids.Database.getField("Defenders", _fieldName);
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
		return ::Math.floor(_lairObject.getResources() * ::Raids.Standard.getPercentageSetting("AgitationResourceModifier"));
	}

	function getResourcesPrefactor( _lairObject )
	{
		local prefactor = 1.0;

		if (_lairObject.m.IsScalingDefenders)
		{
			prefactor *= ::Math.minf(::Raids.Standard.getPercentageSetting("TimeScalePrefactorCeiling"), this.getTimeScalePrefactor());
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

	function getTroopChoices()
	{
		return ::Math.rand(this.Parameters.TroopChoicesFloor, this.Parameters.TroopChoicesCeiling);
	}

	function getViableTroopCandidates( _lairObject )
	{
		local agitation = ::Raids.Lairs.getAgitation(_lairObject);
		local factionName = ::Raids.Lairs.getFactionKey(_lairObject);
		local resources = this.getResourcesForReinforcement(_lairObject);
		local troopChoices = this.getTroopChoices();

		if (!(factionName in ::Raids.Database.Troops))
		{
			return null;
		}

		local troopPool = this.getField("Troops");
		local candidates = troopPool[factionName].filter(function( _index, _troopTable )
		{
			if (_troopTable.Cost > resources)
			{
				return false;
			}

			if (!("Agitation" in _troopTable))
			{
				return true;
			}

			if ("Floor" in _troopTable.Agitation && agitation < _troopTable.Agitation.Floor)
			{
				return false;
			}

			if ("Ceiling" in _troopTable.Agitation && agitation > _troopTable.Agitation.Ceiling)
			{
				return false;
			}

			return true;
		});

		this.resizeTroops(candidates, troopChoices);
		return candidates;
	}

	function isLairAgitated( _lairObject )
	{
		local agitationDescriptors = ::Raids.Lairs.getField("AgitationDescriptors");
		return ::Raids.Lairs.getAgitation(_lairObject) > agitationDescriptors.Relaxed;
	}

	function reinforceDefenders( _lairObject )
	{
		if (!this.isLairAgitated(_lairObject))
		{
			return;
		}

		local troopPool = this.getViableTroopCandidates(_lairObject);

		if (troopPool == null || troopPool.len() == 0)
		{
			return;
		}

		local allocatedResources = ::Math.floor(this.getResourcesForReinforcement(_lairObject) / troopPool.len());
		local selection =
		{
			Troops = []
		};

		foreach( troopTable in troopPool )
		{
			local newTroop = {};

			# Ensure at least one of the chosen troop type, if nominally affordable, can be added.
			local troopCount = ::Math.max(1, ::Math.floor(allocatedResources / troopTable.Cost));

			# Assign fields for the addTroops method to reference.
			newTroop.Type <- troopTable.Type;
			newTroop.Num <- ::Math.min(troopTable.MaxCount, troopCount);
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
