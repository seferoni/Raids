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

	function getTraitField( _traitField, _lairObject )
	{
		local traitTable = this.getTraitTableByLair(_lairObject);

		if (!(_traitField in traitTable))
		{
			return null;
		}

		return traitTable[_traitField];
	}

	function getTrait( _lairObject )
	{
		return ::Raids.Standard.getFlag("LairTrait", _lairObject);
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
	{	// TODO: this needs to account for much. need a flag to determine when it's appropriate to add a trait, including contract behaviour
	// TODO: ensure that when a lair becomes a contract target, there are no after-effects wrt traits.
		if (this.getTrait(_lairObject) != false)
		{
			return;
		}

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

			this.addTrait(traitTable, _lairObject);
			break;
		}

		if (chosenTrait == null)
		{
			return;
		}

		this.injectGold(traitTable, _lairObject);
		this.injectItems(traitTable, _lairObject);
		this.injectTroops(traitTable, _lairObject);
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
};