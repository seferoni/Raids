::Raids.Lairs.Traits <-
{
	function addTrait( _traitTable, _lairObject )
	{
		::Raids.Standard.setFlag("LairTrait", _traitTable.Name, _lairObject);
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
		local trait = this.getTrait(_lairObject);

		if (!trait)
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

		local traitString = ::Raids.Strings.Lairs.Traits[format("%sName", trait)];
		return ::Raids.Standard.constructEntry
		(
			"Trait",
			::Raids.Standard.colourWrap(traitString, ::Raids.Standard.Colour.Gold)
		);
	}

	function getTotalWeight( _weightedArray )
	{
		local totalWeight = 0;

		foreach( tableKey, table in _weightedArray )
		{
			totalWeight += table.Weight;
		}

		return totalWeight;
	}

	function getTrait( _lairObject )
	{
		return ::Raids.Standard.getFlag("LairTrait", _lairObject);
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
		local traitKey = this.getTrait(_lairObject);

		if (traitKey == false)
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
		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("TraitChance"))
		{
			return;
		}

		local factionType = ::Raids.Lairs.getFactionType(_lairObject);
		local nominalTraits = this.getTraitsByFaction(factionType);
		local chosenTrait = this.pickFromWeightedArray(nominalTraits);
		::logInfo("applying " + chosenTrait.Name + " to " + _lairObject.getName())
		this.addTrait(chosenTrait, _lairObject);
		this.applyTraitEffects(_lairObject);
	}

	function injectGold( _traitTable, _lairObject )
	{
		if (!("AddedGold" in _traitTable))
		{
			return;
		}

		local money = ::new("scripts/items/supplies/money_item");
		money.setAmount(_traitTable.AddedGold);
		_lairObject.getLoot().add(money);
	}

	function injectItems( _traitTable, _lairObject )
	{
		if (!("AddedItems" in _traitTable))
		{
			return;
		}

		local lootTable = _traitTable.AddedItems[::Math.rand(0, _traitTable.AddedItems.len() - 1)];

		for ( local i = 0; i < lootTable.Num; i++ )
		{
			_lairObject.getLoot().add(::new(format("scripts/items/%s", lootTable.Type)));
		}
	}

	function injectTroops( _traitTable, _lairObject )
	{
		::logInfo("initially had " + _lairObject.getTroops().len() + " for " + _lairObject.getName())
		if (!("AddedTroops" in _traitTable))
		{
			return;
		}

		::Raids.Lairs.Defenders.addTroops([_traitTable.AddedTroops[::Math.rand(0, _traitTable.AddedTroops.len() - 1)]], _lairObject);
		::logInfo("have " + _lairObject.getTroops().len() + " for " + _lairObject.getName() + " after injection")
	}

	function pickFromWeightedArray( _weightedArray )
	{
		local cumulativeWeight = 0;
		local randomNumber = ::Math.rand(0, this.getTotalWeight(_weightedArray));

		foreach( traitKey, traitTable in _weightedArray )
		{
			cumulativeWeight += traitTable.Weight;

			if (randomNumber < cumulativeWeight)
			{
				return traitKey;
			}
		}
	}

	function setTraitForbiddenState( _boolean, _lairObject )
	{
		::Raids.Standard.setFlag("TraitForbidden", _boolean, _lairObject);
	}
};