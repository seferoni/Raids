::Raids.Lairs.Traits <-
{
	function addTrait( _traitTable, _lairObject )
	{
		::Raids.Standard.setFlag("LairTrait", _traitTable.Name, _lairObject);
	}

	function createTraitEntry( _lairObject )
	{
		local trait = this.getTrait(_lairObject);

		if (!trait)
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

	function getField( _fieldName )
	{
		return ::Raids.Database.getField("Traits", _fieldName);
	}

	function getTrait( _lairObject )
	{
		return ::Raids.Standard.getFlag("LairTrait", _lairObject);
	}

	function getTraitActiveState( _lairObject )
	{
		return ::Raids.Standard.getFlag("TraitActiveState", _lairObject);
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
		local trait = this.getTrait(_lairObject);

		if (trait == false)
		{
			return null;
		}

		return this.getField(trait);
	}

	function getTraitsByFaction( _factionType )
	{
		local traits = [];
		local traitsDatabase = ::Raids.Lairs.getField("Traits");
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
		local chosenTrait = null;
		local factionType = ::Raids.Lairs.getFactionType(_lairObject);
		local nominalTraits = this.getTraitsByFaction(factionType);
		::Raids.Standard.shuffleArray(nominalTraits);

		foreach( traitTable in nominalTraits )
		{
			if (::Math.rand(1, 100) > traitTable.Chance)
			{
				continue;
			}

			chosenTrait = traitTable;
			break;
		}

		if (chosenTrait == null)
		{
			return;
		}

		this.addTrait(chosenTrait, _lairObject);
		this.setTraitActiveState(true, _lairObject);
		this.injectGold(chosenTrait, _lairObject);
		this.injectItems(chosenTrait, _lairObject);
		this.injectTroops(chosenTrait, _lairObject);
	}

	function injectGold( _traitTable, _lairObject )
	{
		if (!"AddedGold" in _traitTable)
		{
			return;
		}

		local money = ::new("scripts/items/supplies/money_item");
		money.setAmount(_traitTable.AddedGold);
		_lairObject.getLoot().add(money);
	}

	function injectItems( _traitTable, _lairObject )
	{
		if (!"AddedItems" in _traitTable)
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
		if (!"AddedTroops" in _traitTable)
		{
			return;
		}

		local troopTable = _traitTable.AddedTroops[::Math.rand(0, _traitTable.AddedTroops.len() - 1)];
		::Raids.Lairs.Defenders.addTroops(troopTable, _lairObject);
	}

	function setTraitActiveState( _boolean, _lairObject )
	{
		::Raids.Standard.setFlag("TraitActiveState", _boolean, _lairObject);
	}
};