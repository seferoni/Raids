::Raids.Edicts.Procedures <-
{
	function executeAgitationProcedure( _lairObject )
	{
		this.resetContainer(this.findEdict("Agitation", _lairObject), _lairObject, false);
		::Raids.Lairs.setAgitation(_lairObject, ::Raids.Standard.getProcedures().Increment);
	}

	function executeDiminutionProcedure( _lairObject )
	{	// TODO: look at the official bug report filed for diminution on nexus.
		local garbage = [];
		local troops = _lairObject.getTroops();
		local removalCount = ::Math.ceil(this.Parameters.DiminutionPrefactor * ::Raids.Lairs.getAgitation(_lairObject) * troops.len());

		if (removalCount >= troops.len() || removalCount == 0)
		{
			return;
		}

		while( garbage.len() < removalCount )
		{
			garbage.push(troops[::Math.rand(0, troops.len() - 1)]);
		}

		foreach( troop in garbage )
		{
			local index = troops.find(troop);

			if (index != null)
			{
				troops.remove(index);
			}
		}

		_lairObject.updateStrength();
	}

	function executeNullificationProcedure( _lairObject )
	{
		this.clearEdicts(_lairObject);
		this.clearHistory(_lairObject);
		::Raids.Lairs.updateProperties(_lairObject);
	}

	function executeOpportunismProcedure( _lairObject )
	{
		::Raids.Lairs.repopulateNamedLoot(_lairObject);
	}
};