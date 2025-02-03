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

		local traitString = ::Raids.Strings.Lairs.Traits[trait]

		return ::Raids.Standard.constructEntry
		(
			"Trait",
			format(::Raids.Strings.Lairs.Common.Traits, ::Raids.Standard.colourWrap(traitString, ::Raids.Standard.Colour.Gold))
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
	{
		local factionType = ::Raids.Lairs.getFactionType(_lairObject);
		local nominalTraits = this.getTraitsByFaction(factionType);
		::Raids.Standard.shuffleArray(nominalTraits);

		foreach( traitTable in nominalTraits )
		{
			if (::Math.rand(1, 100) > traitTable.Chance )
			{
				continue;
			}

			this.addTrait(traitTable, _lairObject);
			break;
		}

		this.injectItems(traitTable, _lairObject);
		this.injectTroops(traitTable, _lairObject);
	}

	function injectGold( _count, _lairObject )
	{

	}

	function injectItems( _traitTable, _lairObject )
	{
		if (!"AddedItems" in _traitTable)
		{
			return;
		}

		// TODO: if the associated item is gold, this should probably call something else
		local lootTable = _traitTable.AddedItems[::Math.rand(0, _traitTable.AddedItems.len() - 1)];

		for ( local i = 0; i < lootTable.Num; i++ )
		{
			_lairObject.getLoot().add(::new(format("scripts/items/%s", lootTable.Type)));
		}
	}

	function injectTroops( _traitTable, _lairObject )
	{
		// TODO:
	}
};