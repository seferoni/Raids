::Raids.Edicts <-
{
	Parameters =
	{
		DirectoryPath = "scripts/items/special/edicts/",
		ResourcesPrefactor = 0.001,
		WritingInstrumentsChance = 66,
		WritingInstrumentsSelectionSize = 3
	}

	function addToHistory( _sugaredID, _lairObject )
	{
		local history = this.getHistory(_lairObject);
		local newHistory = format("%s%s", history == false ? "" : format("%s, ", history), _sugaredID);
		::Raids.Standard.setFlag("EdictHistory", newHistory, _lairObject);
	}

	function clearEdicts( _lairObject )
	{
		foreach( container in this.getField("Containers") )
		{
			this.resetContainer(container, _lairObject);
		}
	}

	function clearHistory( _lairObject )
	{
		::Raids.Standard.setFlag("EdictHistory", false, _lairObject);
	}

	function createEdict( _writingInstruments = null )
	{
		local edicts = _writingInstruments == null ? this.getAllEdictsAsFiles() : _writingInstruments.getEdictSelectionAsFiles();
		return ::new(edicts[::Math.rand(0, edicts.len() - 1)]);
	}

	function createHistoryEntry( _lairObject )
	{
		if (!::Raids.Standard.getFlag("EdictHistory", _lairObject))
		{
			return null;
		}

		return ::Raids.Standard.constructEntry
		(
			"History",
			::Raids.Standard.colourWrap(this.getHistoryAsString(_lairObject), ::Raids.Standard.Colour.Red)
		);
	}

	function createTooltipEntry( _edictName, _activeState )
	{
		return ::Raids.Standard.constructEntry
		(
			_activeState,
			format(::Raids.Strings.Edicts.Common.LairActiveEdict, _edictName, _activeState)
		);
	}

	function createVacantEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Vacant",
			::Raids.Strings.Edicts.Common.LairVacantEdict
		);
	}

	function executeEdictProcedure( _container, _lairObject )
	{
		local sugaredID = ::Raids.Standard.getFlag(_container, _lairObject);
		local procedure = format("execute%sProcedure", sugaredID);

		if (this.getField("CycledEdicts").find(sugaredID) != null)
		{
			this.resetContainer(_container, _lairObject);
			this.addToHistory(sugaredID, _lairObject);
		}
		else
		{
			this.resetContainerTime(_container, _lairObject);
		}

		if (!(procedure in this.Procedures))
		{
			return;
		}

		this.Procedures[procedure](_lairObject);
	}

	function findEdict( _sugaredID, _lairObject, _filterActive = false )
	{
		local edictContainer = false;

		foreach( container in this.getField("Containers") )
		{
			if (::Raids.Standard.getFlag(container, _lairObject) == _sugaredID)
			{
				edictContainer = container;
				break;
			}
		}

		if (!edictContainer)
		{
			return false;
		}

		if (!_filterActive || !::Raids.Standard.getFlag(format("%sTime", edictContainer), _lairObject))
		{
			return edictContainer;
		}

		return false;
	}

	function findEdictInHistory( _sugaredID, _lairObject )
	{
		local history = ::Raids.Standard.getFlag("EdictHistory", _lairObject);

		if (history == false)
		{
			return false;
		}

		if (history.find(_sugaredID) != null)
		{
			return true;
		}

		return false;
	}

	function getAgitationDecayOffset( _lairObject )
	{
		local offset = 0;

		if (this.findEdict("Stasis", _lairObject, true) != false)
		{
			offset = this.getField("StasisOffset") * (::Raids.Lairs.getAgitation(_lairObject) - 1);
		}

		return offset;
	}

	function getAllWritingInstrumentsInstancesInStash()
	{
		return ::World.Assets.getStash().getItems().filter(@(_index, _item) _item != null && _item.getID() == "misc.raids_writing_instruments_item");
	}

	function getAllEdictsAsFiles()
	{
		return ::IO.enumerateFiles(this.Parameters.DirectoryPath);
	}

	function getContainerEntries( _lairObject )
	{
		local entries = [];
		local vacantEntry = this.createVacantEntry();
		local naiveContainers = this.getField("Containers");
		local occupiedContainers = this.getOccupiedContainers(_lairObject);

		if (occupiedContainers.len() == 0)
		{
			entries.resize(naiveContainers.len(), vacantEntry);
			return entries;
		}

		local push = @(_entry) ::Raids.Standard.push(_entry, entries);

		foreach( container in occupiedContainers )
		{
			local inDiscovery = ::Raids.Standard.getFlag(format("%sTime", container), _lairObject) != false;
			local sugaredID = ::Raids.Standard.getFlag(container, _lairObject);
			local activeState = inDiscovery ? "Discovery" : "Active";
			push(this.createTooltipEntry(sugaredID, activeState));
		}

		if (entries.len() < naiveContainers.len())
		{
			local iterations = naiveContainers.len() - entries.len();

			for( local i = 0; i < iterations; i++ )
			{
				push(vacantEntry);
			}
		}

		return entries;
	}

	function getEdictIDBySugaredID( _sugaredID )
	{
		local edictFileName = format("raids_edict_of_%s_item", prependedString, ::Raids.Standard.setCase(_sugaredID, ::Raids.Standard.Case.Lower));
		return edictFileName;
	}

	function getEdictFilePathBySugaredID( _sugaredID )
	{
		local prependedString = format("%s%s", this.Parameters.DirectoryPath, "raids_edict_of_");
		local edictFileName = format("%s%s_item", prependedString, ::Raids.Standard.setCase(_sugaredID, ::Raids.Standard.Case.Lower));
		return edictFileName;
	}

	function getField( _fieldName )
	{
		return ::Raids.Database.getField("Edicts", _fieldName);
	}

	function getFirstQueuedWritingInstrumentsInstance()
	{
		local instances = this.getAllWritingInstrumentsInstancesInStash();

		if (instances.len() == 0)
		{
			return null;
		}

		foreach( candidate in candidates )
		{
			local selectionMode = candidate.getEdictSelectionMode();

			if (selectionMode != candidate.SelectionModes.Indiscriminate)
			{
				return candidate;
			}
		}

		return candidates[0];
	}

	function getHistory( _lairObject )
	{
		return ::Raids.Standard.getFlag("EdictHistory", _lairObject);
	}

	function getHistoryAsString( _lairObject )
	{
		local historyArray = ::Raids.Standard.getListAsArray(this.getHistory(_lairObject));
		local historyString = "";

		foreach( entry in historyArray )
		{
			::Raids.Standard.appendToStringList(::Raids.Strings.Edicts[entry].NameAbbreviated, historyString);
		}

		return historyString;
	}

	function getLegibilityEntry( _lairObject )
	{
		if (!this.findEdict("Legibility", _lairObject))
		{
			return null;
		}

		return this.createTooltipEntry("Legibility", "Discovery");
	}

	function getNamedLootChanceOffset( _lairObject )
	{
		local offset = 0.0;
		local agitation = ::Raids.Lairs.getAgitation(_lairObject);

		if (this.findEdict("Prospecting", _lairObject, true) != false)
		{
			offset = this.getField("ProspectingOffset") * agitation;
		}

		return offset;
	}

	function getNamedLootEntry( _lairObject )
	{
		if (!::Raids.Standard.getParameter("ShowNamedLootEntry"))
		{
			return null;
		}

		local count = 0;
		local loot = _lairObject.getLoot().getItems();
		local namedLootChance = ::Raids.Lairs.getNamedLootChance(_lairObject) + this.getNamedLootChanceOffset(_lairObject);

		foreach( item in loot )
		{
			if (item != null && item.isItemType(::Const.Items.ItemType.Named))
			{
				count++;
			}
		}

		local fragmentA = ::Raids.Standard.colourWrap(format(::Raids.Strings.Generic.NamedCount, count), ::Raids.Standard.Colour[count == 0 ? "Red" : "Green"]);
		local fragmentB = ::Raids.Standard.colourWrap(format("%i%%", namedLootChance), ::Raids.Standard.Colour.Green);
		return ::Raids.Standard.constructEntry
		(
			count == 0 ? "False" : "Special",
			format("%s (%s)", fragmentA, fragmentB)
		);
	}

	function getNonviableEntries( _lairObject )
	{
		local entries = [];
		local push = @(_entry) ::Raids.Standard.push(_entry, entries);

		push(this.getLegibilityEntry(_lairObject));
		push(this.getSpecialEntries(_lairObject));
		return entries;
	}

	function getOccupiedContainers( _lairObject )
	{
		local occupiedContainers = [];
		local occupied = @(_container) ::Raids.Standard.getFlag(_container, _lairObject) != false;

		foreach( container in this.getField("Containers") )
		{
			if (occupied(container))
			{
				occupiedContainers.push(container);
			}
		}

		return occupiedContainers;
	}

	function getSpecialEntries( _lairObject )
	{
		local entries = [];
		local push = @(_entry) ::Raids.Standard.push(_entry, entries);

		push(this.getNamedLootEntry(_lairObject));
		push(this.createHistoryEntry(_lairObject));
		return entries;
	}

	function getSugaredID( _edictID, _isFileName = false )
	{
		local culledString = _isFileName ? format("%s%s", this.Parameters.DirectoryPath, "raids_edict_of_") : "special.raids_edict_of_";
		local sugaredID = ::Raids.Standard.setCase(_edictID.slice(culledString.len()), ::Raids.Standard.Case.Upper);
		return sugaredID;
	}

	function getTreasureOffset( _lairObject )
	{
		local offset = 0;

		if (this.findEdictInHistory("Abundance", _lairObject) != false)
		{
			offset = ::Math.min(this.getField("AbundanceCeiling"), this.getField("AbundanceOffset") + ::Raids.Lairs.getAgitation(_lairObject));
		}

		return offset;
	}

	function getTooltipEntries( _lairObject )
	{
		local entries = [];
		local push = @(_entry) ::Raids.Standard.push(_entry, entries);

		push(this.getContainerEntries(_lairObject));
		push(this.getSpecialEntries(_lairObject));
		return entries;
	}

	function isLairViable( _lairObject )
	{
		if (!_lairObject.m.IsShowingBanner)
		{
			return false;
		}

		local factionType = ::World.FactionManager.getFaction(_lairObject.getFaction()).getType();
		local viableFactions = this.findEdict("Legibility", _lairObject, true) != false ? ::Raids.Lairs.Factions : this.getField("ConnateFactions");

		if (viableFactions.find(factionType) != null)
		{
			return true;
		}

		local override = ::Raids.Lairs.getOverride(_lairObject);

		if (override != null && viableFactions.find(override.Faction) != null)
		{
			return true;
		}

		return false;
	}

	function refreshEdicts( _lairObject )
	{
		if (!::Raids.Standard.getFlag("EdictHistory", _lairObject))
		{
			return;
		}

		local viableEdicts = this.getField("CycledEdicts").filter(@(_index, _sugaredID) ::Raids.Edicts.findEdictInHistory(_sugaredID, _lairObject));

		foreach( sugaredID in viableEdicts )
		{
			local procedure = format("execute%sProcedure", sugaredID);

			if (!(procedure in this.Procedures))
			{
				continue;
			}

			this.Procedures[procedure](_lairObject);
		}
	}

	function resetContainer( _container, _lairObject, _resetTime = true )
	{
		::Raids.Standard.setFlag(_container, false, _lairObject);

		if (_resetTime)
		{
			this.resetContainerTime(_container, _lairObject);
		}
	}

	function resetContainerTime( _container, _lairObject )
	{
		::Raids.Standard.setFlag(format("%sTime", _container), false, _lairObject);
	}

	function updateEdicts( _lairObject )
	{
		local occupiedContainers = this.getOccupiedContainers(_lairObject);

		if (occupiedContainers.len() == 0)
		{
			return;
		}

		local edictDates = occupiedContainers.map(@(_container) ::Raids.Standard.getFlag(format("%sTime", _container), _lairObject));
		local edictDurations = occupiedContainers.map(@(_container) ::Raids.Standard.getFlag(format("%sDuration", _container), _lairObject));

		for( local i = 0; i < occupiedContainers.len(); i++ )
		{
			if (edictDates[i] == false)
			{
				continue;
			}

			if (::World.getTime().Days - edictDates[i] < edictDurations[i])
			{
				continue;
			}

			this.executeEdictProcedure(occupiedContainers[i], _lairObject);
		}
	}

	function updateWritingInstruments( _writingInstruments )
	{
		if (writingInstruments.getEdictSelectionMode() == this.getField("SelectionModes").Indiscriminate)
		{
			return;
		}

		local stash = ::World.Assets.getStash();
		writingInstruments.setStacks(::Raids.Standard.getProcedures().Decrement);

		if (writingInstruments.isFlaggedForRemoval())
		{
			stash.remove(writingInstruments);
		}
	}
};