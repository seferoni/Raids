local Raids = ::RPGR_Raids;
Raids.Lairs.Defenders <-
{
	Parameters =
	{
		ResourcesThresholdPrefactorCeiling = 2.0,
		ResourcesThresholdPrefactorFloor = 0.75,
		SpawnListLengthPrefactor = 0.25,
		TimeScalePrefactorCeiling = 1.5
	}

	function addTroops( _troopsTable, _lairObject )
	{
		_lairObject.m.Troops = [];
		_lairObject.m.DefenderSpawnDay = ::World.getTime().Days;

		foreach( troop in _troopsTable.Troops )
		{
			for( local i = 0; i < troop.Num; i++ )
			{
				::Const.World.Common.addTroop(_lairObject, troop, false);
			}
		}

		_lairObject.updateStrength();
	}

	function createDefenders( _lairObject )
	{
		local candidate = this.getCandidate(_lairObject);
		this.addTroops(candidate, _lairObject);
	}

	function getCandidate( _lairObject )
	{
		# Prepare variables associated with lair properties.
		local spawnList = _lairObject.getDefenderSpawnList(),
		thresholdPrefactor = this.Parameters.ResourcesThresholdPrefactorFloor;

		# Get resources scaled in a fashion similar to the vanilla algorithm.
		local resources = _lairObject.getResources() * this.getResourcesPrefactor(_lairObject);

		# Retrieve all candidate templates from the spawnlist that are above 75% and below 100% of the scaled resources value.
		local candidates = spawnList.filter(@(_index, _party) _party.Cost <= resources && _party.Cost >= resources * thresholdPrefactor);

		if (candidates.len() == 0)
		{	# If no candidates can be found through the above heuristic, resort to a simpler algorithm.
			return this.getNaiveCandidate(_lairObject);
		}

		# Return a random candidate from this list.
		local candidate = candidates[::Math.rand(0, candidates.len() - 1)];
		
		return candidate;
	}

	function getNaiveCandidate( _lairObject )
	{
		local spawnList = _lairObject.getDefenderSpawnList();

		# Cap template candidates to the bottom fourth of the total entries in the spawnlist.
		local ceiling = ::Math.floor((spawnList.len() - 1) * this.Parameters.SpawnListLengthPrefactor);

		return spawnList[::Math.rand(0, ceiling)];
	}

	function getTimeScalePrefactor()
	{	# These values are taken verbatim from the vanilla codebase.
		return (1.0 + ::World.getTime().Days * 0.0075);
	}

	function getResourcesPrefactor( _lairObject )
	{
		local prefactor = 1.0;

		if (_lairObject.m.IsScalingDefenders)
		{
			prefactor *= ::Math.minf(this.Parameters.TimeScalePrefactorCeiling, this.getTimeScalePrefactor());
		}

		if (!_lairObject.isAlliedWithPlayer())
		{
			prefactor *= ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()];
		}

		return prefactor;
	}
}