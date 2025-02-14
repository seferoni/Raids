::Raids.Lairs.Traits <-
{
	Parameters =
	{
		ItemCountBase = ::Math.rand(1, 3)
	}

	function addTrait( _traitTable, _lairObject )
	{
		local pickRandom = function( _propertyKey )
		{
			if (!(_propertyKey in _traitTable))
			{
				return false;
			}

			local propertyArray = _traitTable[_propertyKey];
			return ::Math.rand(0, propertyArray.len() - 1);
		};

		::Raids.Standard.setFlag("LairTraitKey", _traitTable.Name, _lairObject);
		::Raids.Standard.setFlag("LairTraitTroopIndex", pickRandom("AddedTroops"), _lairObject);
	}

	function createTraitEntry( _lairObject )
	{
		if (!::Raids.Standard.getParameter("ShowLairTraitEntry"))
		{
			return null;
		}

		local traitKey = this.getTraitProperties(_lairObject).TraitKey;

		if (!traitKey)
		{
			return null;
		}

		if (this.getTraitForbiddenState(_lairObject))
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

	function getDescription( _lairObject )
	{
		local traitKey = this.getTraitProperties(_lairObject).TraitKey;

		if (!traitKey)
		{
			return "";
		}

		return ::Raids.Strings.Lairs.Traits[format("%sDescription", traitKey)];
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
			TraitInitialised = ::Raids.Standard.getFlag("LairTraitInitialised", _lairObject),
			TraitKey = ::Raids.Standard.getFlag("LairTraitKey", _lairObject),
			TraitTroopIndex = ::Raids.Standard.getFlag("LairTraitTroopIndex", _lairObject)
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

	function getViableTraitsByFaction( _factionType )
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

		::Raids.Standard.setFlag("LairTraitInitialised", true, _lairObject);

		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("TraitChance"))
		{
			return;
		}

		local factionType = ::Raids.Lairs.getFactionType(_lairObject);
		local nominalTraits = this.getViableTraitsByFaction(factionType);
		local chosenTrait = this.pickFromWeightedArray(nominalTraits);
		::logInfo("applying " + chosenTrait.Name + " to " + _lairObject.getName())
		this.addTrait(chosenTrait, _lairObject);
	}

	function injectItems( _lootTable, _lairObject )
	{
		local traitTable = this.getTraitTableByLair(_lairObject);

		if ("AddedGold" in traitTable)
		{
			local money = ::new("scripts/items/supplies/money_item");
			money.setAmount(traitTable.AddedGold);
			_lootTable.push(money);
		}

		if (!("AddedItems" in traitTable))
		{
			::logInfo("no items to add, aborting")
			return;
		}

		::logInfo("injecting items");
		local count = this.Parameters.ItemCountBase + ::Raids.Lairs.getAgitation(_lairObject);
		local itemArray = traitTable.AddedItems;

		for( local i = 0; i < count; i++ )
		{
			local script = itemArray[::Math.rand(0, itemArray.len() - 1)];
			::logInfo("injected " + script);
			_lootTable.push(::new(script));
		}
	}

	function injectTroops( _lairObject )
	{	::logInfo("initially had " + _lairObject.getTroops().len() + " for " + _lairObject.getName())
		local traitTable = this.getTraitTableByLair(_lairObject);

		if (!("AddedTroops" in traitTable))
		{
			return;
		}

		local troopIndex = this.getTraitProperties(_lairObject).TraitTroopIndex;
		::Raids.Lairs.Defenders.addTroops([traitTable.AddedTroops[troopIndex]], _lairObject);
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