::Raids.Lairs.Traits <-
{
	function addTrait( _traitTable, _lairObject )
	{
		::Raids.Standard.setFlag("LairTrait", _traitTable.Name, _lairObject);
		// TODO: write assignTraitProperties here
	}

	function applyTraitEffects( _lairObject )
	{
		if (this.getTraitForbiddenState(_lairObject))
		{
			return;
		}

		local traitTable = this.getTraitTableByLair(_lairObject);

		if (traitTable == null)
		{
			return;
		}

		this.injectGold(traitTable, _lairObject);
		this.injectItems(traitTable, _lairObject);
		this.injectTroops(traitTable, _lairObject);
	}

	function createTraitEntry( _lairObject )
	{
		local traitKey = this.getTraitProperties(_lairObject).TraitKey;

		if (!traitKey)
		{
			return null;
		}

		if (this.getTraitForbiddenState(_lairObject))
		{
			return null;
		}

		if (!::Raids.Standard.getParameter("ShowLairTraitEntry"))
		{
			return null;
		}

		local traitString = ::Raids.Strings.Lairs.Traits[format("%sName", traitKey)];
		return ::Raids.Standard.constructEntry
		(
			"Trait",
			::Raids.Standard.colourWrap(traitString, ::Raids.Standard.Colour.Gold)
		);
	}

	function getTotalWeight( _weightedArray )
	{
		local totalWeight = 0;

		foreach( index, traitTable in _weightedArray )
		{
			totalWeight += traitTable.Weight;
		}

		return totalWeight;
	}

	function getTraitProperties( _lairObject )
	{
		local properties =
		{
			TraitKey = ::Raids.Standard.getFlag("LairTrait", _lairObject),
			TraitTroopIndex = ::Raids.Standard.getFlag("LairTraitTroopIndex", _lairObject),
			TraitItemIndex = ::Raids.Standard.getFlag("LairTraitItemIndex", _lairObject),
			TraitGoldValue = ::Raids.Standard.getFlag("LairTraitGoldValue", _lairObject)
		};
		return properties;
	}

	function getTraitTables()
	{
		return ::Raids.Lairs.getField("Traits");
	}

	function getTraitForbiddenState( _lairObject )
	{
		return ::Raids.Standard.getFlag("TraitForbidden", _lairObject);
	}

	function getTraitField( _traitField, _lairObject )
	{
		local traitTable = this.getTraitTableByLair(_lairObject);

		if (!(_traitField in traitTable))
		{
			return null;
		}

		return traitTable[_traitField];
	}

	function getTraitTableByLair( _lairObject )
	{
		local traitKey = this.getTraitProperties(_lairObject).TraitKey;

		if (!traitKey)
		{
			return null;
		}

		local traitsDatabase = this.getTraitTables();
		return traitsDatabase[traitKey];
	}

	function getTraitsByFaction( _factionType )
	{
		local traits = [];
		local traitsDatabase = this.getTraitTables();
		local processTable = function( _tableKey, _table )
		{
			_table.Name <- _tableKey;
			traits.push(_table);
		};

		foreach( traitKey, traitTable in traitsDatabase )
		{
			if (!("Factions" in traitTable))
			{
				processTable(traitKey, clone traitTable);
				continue;
			}

			if (traitTable.Factions.find(_factionType) != null)
			{
				processTable(traitKey, clone traitTable);
				continue;
			}
		}

		return traits;
	}

	function initialiseLairTrait( _lairObject )
	{
		if (this.getTraitForbiddenState(_lairObject))
		{
			return;
		}

		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("TraitChance"))
		{
			return;
		}

		local factionType = ::Raids.Lairs.getFactionType(_lairObject);
		local nominalTraits = this.getTraitsByFaction(factionType);
		local chosenTrait = this.pickFromWeightedArray(nominalTraits);
		::logInfo("applying " + chosenTrait.Name + " to " + _lairObject.getName())
		this.addTrait(chosenTrait, _lairObject);
	}

	function injectTroops( _traitTable, _lairObject )
	{
		::logInfo("initially had " + _lairObject.getTroops().len() + " for " + _lairObject.getName())
		if (!("AddedTroops" in _traitTable))
		{
			return;
		}

		local troopIndex = ::Math.rand(0, _traitTable.AddedTroops.len() - 1);
		::Raids.Standard.setFlag("TraitTroopIndex", troopIndex, _lairObject);
		::Raids.Lairs.Defenders.addTroops([_traitTable.AddedTroops[troopIndex]], _lairObject);
		::logInfo("have " + _lairObject.getTroops().len() + " for " + _lairObject.getName() + " after injection")
	}

	function pickFromWeightedArray( _weightedArray )
	{
		local cumulativeWeight = 0;
		local randomNumber = ::Math.rand(0, this.getTotalWeight(_weightedArray));

		foreach( index, traitTable in _weightedArray )
		{
			cumulativeWeight += traitTable.Weight;

			if (cumulativeWeight >= randomNumber)
			{
				return traitTable;
			}
		}
	}

	function setTraitForbiddenState( _boolean, _lairObject )
	{
		::Raids.Standard.setFlag("TraitForbidden", _boolean, _lairObject);
	}
};