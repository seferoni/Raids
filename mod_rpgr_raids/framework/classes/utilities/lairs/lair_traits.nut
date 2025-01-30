::Raids.Lairs.Traits <-
{
	function addTrait( _traitTable, _lairObject )
	{
		::Raids.Standard.setFlag("LairTrait", _traitTable.Name, _lairObject);
	}

	function createTraitEntry( _lairObject )
	{	// TODO: this needs a special colour. make it gold! also add a trait entry to the icons database.

	}

	function getField( _fieldName )
	{
		return ::Raids.Database.getField("Traits", _fieldName);
	}

	function getTrait( _lairObject )
	{

	}

	function getTraitsByFaction( _factionType )
	{	// TODO: all we really seem to require are the name and chance values. perhaps this could be simplified?
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
	}
};