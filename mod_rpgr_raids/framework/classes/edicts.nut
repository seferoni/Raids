::Raids.Edicts <-
{
	Parameters =
	{
		AbundanceCeiling = 3,
		AbundanceOffset = 1,
		DirectoryPath = "scripts/items/special/edicts/",
		DiminutionPrefactor = 0.06,
		EdictSelectionSize = 3,
		ProspectingOffset = 8.0,
		ResourcesPrefactor = 0.001,
		StasisOffset = 1
		WritingInstrumentsChance = 66
	}

	function addToHistory( _edictName, _lairObject )
	{
		local history = ::Raids.Standard.getFlag("EdictHistory", _lairObject);
		local newHistory = format("%s%s", history == false ? "" : format("%s, ", history), _edictName);
		::Raids.Standard.setFlag("EdictHistory", newHistory, _lairObject);
	}

	function createEdict( _writingInstruments = null )
	{
		local edicts = _writingInstruments == null ? this.getEdictFiles() : _writingInstruments.getEdictSelectionAsFiles();
		return ::new(edicts[::Math.rand(0, edicts.len() - 1)]);
	}

	function clearEdicts( _lairObject )
	{
		foreach( container in this.Containers )
		{
			this.resetContainer(container, _lairObject);
		}
	}

	function clearHistory( _lairObject )
	{
		::Raids.Standard.setFlag("EdictHistory", false, _lairObject);
	}

	function createHistoryEntry( _lairObject )
	{
		return ::Raids.Standard.constructEntry
		(
			"History",
			::Raids.Standard.colourWrap(::Raids.Standard.getFlag("EdictHistory", _lairObject), ::Raids.Standard.Colour.Red)
		);
	}

	function createTooltipEntry( _lairObject, _iconPath, _edictName, _activityState )
	{	// TODO: get rid of this. replace it with the constructEntry method in Standard
		local entry = clone this.Tooltip.Template;
		entry.icon = format("ui/icons/%s", _iconPath);
		entry.text = format("Edict: %s (%s)", _edictName, _activityState);
		return entry;
	}

	function executeAgitationProcedure( _lairObject )
	{
		this.resetContainer(this.findEdict("Agitation", _lairObject), _lairObject, false);
		::Raids.Lairs.setAgitation(_lairObject, ::Raids.Lairs.Procedures.Increment);
	}

	function executeDiminutionProcedure( _lairObject )
	{
		local garbage = [];
		local troops = _lairObject.getTroops();
		local removalCount = ::Math.ceil(this.Parameters.DiminutionPrefactor * ::Raids.Standard.getFlag("Agitation", _lairObject) * troops.len());

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

	function executeEdictProcedure( _container, _lairObject )
	{
		local edictID = ::Raids.Standard.getFlag(_container, _lairObject);
		local edictName = this.getEdictName(edictID);
		local procedure = format("execute%sProcedure", edictName);

		if (this.CycledEdicts.find(edictName) != null)
		{
			this.resetContainer(_container, _lairObject);
			this.addToHistory(edictName, _lairObject);
		}
		else
		{
			this.resetContainerTime(_container, _lairObject);
		}

		if (!(procedure in this))
		{
			return;
		}

		this[procedure](_lairObject);
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

	function findEdict( _edictName, _lairObject, _filterActive = false )
	{
		local edictContainer = false;
		local edictID = this.getEdictID(_edictName);

		foreach( container in this.Containers )
		{
			if (::Raids.Standard.getFlag(container, _lairObject) == edictID)
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

	function findEdictInHistory( _edictName, _lairObject )
	{
		local history = ::Raids.Standard.getFlag("EdictHistory", _lairObject);

		if (history == false)
		{
			return false;
		}

		if (history.find(_edictName) != null)
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
			offset = this.Parameters.StasisOffset * (::Raids.Standard.getFlag("Agitation", _lairObject) - 1);
		}

		return offset;
	}

	function getContainerEntries( _lairObject )
	{
		local entries = [];
		local occupiedContainers = this.getOccupiedContainers(_lairObject);

		if (occupiedContainers.len() == 0)
		{
			entries.resize(this.Containers.len(), this.Tooltip.Template);
			return entries;
		}

		foreach( container in occupiedContainers )
		{
			local inDiscovery = ::Raids.Standard.getFlag(format("%sTime", container), _lairObject) != false;
			local edictName = this.getEdictName(::Raids.Standard.getFlag(container, _lairObject));

			# Create tooltip entry.
			local iconPath = this.Tooltip.Icons.Contracted[inDiscovery ? "Discovery" : "Active"],
			activityState = inDiscovery ? "Discovery" : "Active";
			entries.push(this.createTooltipEntry(_lairObject, iconPath, edictName, activityState));
		}

		if (entries.len() < this.Containers.len())
		{
			local iterations = this.Containers.len() - entries.len();

			for( local i = 0; i < iterations; i++ )
			{
				entries.push(this.Tooltip.Template);
			}
		}

		return entries;
	}

	function getEdictFileName( _edictName )
	{
		local prependedString = format("%s%s", this.Parameters.DirectoryPath, "edict_of_");
		local edictFileName = format("%s%s", prependedString, ::Raids.Standard.setCase(_edictName, "tolower"));
		return edictFileName;
	}

	function getEdictFiles()
	{
		return ::IO.enumerateFiles(this.Parameters.DirectoryPath);
	}

	function getEdictID( _edictName )
	{
		local prependedString = "special.edict_of_";
		local edictID = format("%s%s", prependedString,  ::Raids.Standard.setCase(_edictName, "tolower"));
		return edictID;
	}

	function getEdictName( _edictID, _isFileName = false )
	{
		local culledString = _isFileName ? format("%s%s", this.Parameters.DirectoryPath, "edict_of_") : "special.edict_of_";
		local edictName = ::Raids.Standard.setCase(_edictID.slice(culledString.len()), "toupper");
		return edictName;
	}

	function getField( _fieldName )
	{
		return ::Raids.Database.getTopLevelField("Edicts", _fieldName);
	}

	function getLegibilityEntry( _lairObject )
	{
		local entry = this.createTooltipEntry(_lairObject, this.Tooltip.Icons.Contracted.Discovery, "Legibility", "Discovery");
		return entry;
	}

	function getNamedLootChanceOffset( _lairObject )
	{
		local offset = 0.0;
		local agitation = ::Raids.Standard.getFlag("Agitation", _lairObject);

		if (this.findEdict("Prospecting", _lairObject, true) != false)
		{
			offset = this.Parameters.ProspectingOffset * agitation;
		}

		return offset;
	}

	function getNamedLootEntry( _lairObject )
	{
		local entry = clone this.Tooltip.Template;
		local count = 0;

		# Get naive named loot chance.
		local naiveNamedLootChance = ::Raids.Lairs.getNamedLootChance(_lairObject);

		# Get post-offset named loot chance.
		local namedLootChance = naiveNamedLootChance + this.getNamedLootChanceOffset(_lairObject);

		# Get contents of lair stash.
		local loot = _lairObject.getLoot().getItems();

		# Tally named item count.
		foreach( item in loot )
		{
			if (item != null && item.isItemType(::Const.Items.ItemType.Named)) count++;
		}

		# Assign text fragment corresponding to currently housed named items.
		local fragmentA = ::Raids.Standard.colourWrap(format("Famed (%i)", count), ::Raids.Standard.Colour[count == 0 ? "Red" : "Green"]);

		# Assign text fragment corresponding to current named loot chance.
		local fragmentB = ::Raids.Standard.colourWrap(format("%i%%", namedLootChance), ::Raids.Standard.Colour.Green);
		# Create entry.
		entry.icon = format(this.Tooltip.Icons[count == 0 ? "NamedEmpty" : "NamedPresent"]);
		entry.text = format("%s (%s)", fragmentA, fragmentB);

		return entry;
	}

	function getNonviableEntries( _lairObject )
	{
		local entries = [];

		if (this.findEdict("Legibility", _lairObject) != false)
		{
			entries.push(this.getLegibilityEntry(_lairObject));
		}

		entries.extend(this.getSpecialEntries(_lairObject));
		return entries;
	}

	function getOccupiedContainers( _lairObject )
	{
		local occupiedContainers = [];
		local occupied = @(_container) ::Raids.Standard.getFlag(_container, _lairObject) != false;

		foreach( container in this.Containers )
		{
			if (occupied(container)) occupiedContainers.push(container);
		}

		return occupiedContainers;
	}

	function getSpecialEntries( _lairObject )
	{
		local entries = [];

		if (::Raids.Standard.getParameter("ShowNamedLootEntry"))
		{
			entries.push(this.getNamedLootEntry(_lairObject));
		}

		if (::Raids.Standard.getFlag("EdictHistory", _lairObject) != false)
		{
			entries.push(this.createHistoryEntry(_lairObject));
		}

		return entries;
	}

	function getTreasureOffset( _lairObject )
	{
		local offset = 0;

		if (this.findEdictInHistory("Abundance", _lairObject) != false)
		{
			offset = ::Math.min(this.Parameters.AbundanceCeiling, this.Parameters.AbundanceOffset * ::Raids.Standard.getFlag("Agitation", _lairObject));
		}

		return offset;
	}

	function getTooltipEntries( _lairObject )
	{
		local entries = this.getContainerEntries(_lairObject);
		entries.extend(this.getSpecialEntries(_lairObject));
		return entries;
	}

	function isLairViable( _lairObject )
	{
		if (!_lairObject.m.IsShowingBanner)
		{
			return false;
		}

		local factionType = ::World.FactionManager.getFaction(_lairObject.getFaction()).getType();
		local factions = this.findEdict("Legibility", _lairObject, true) != false ? ::Raids.Lairs.Factions : this.getField("Factions");
		local viableFactions = factions.map(@(_factionName) ::Raids.Lairs.getFactionType(_factionName));

		if (viableFactions.find(factionType) != null)
		{
			return true;
		}

		if (this.getField("Overrides").find(_lairObject.getTypeID()) != null)
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

		local viableEdicts = this.getField("CycledEdicts").filter(@(_index, _edictName) ::Raids.Edicts.findEdictInHistory(_edictName, _lairObject));

		foreach( edictName in viableEdicts )
		{
			local procedure = format("execute%sProcedure", edictName);

			if (!(procedure in this))
			{
				continue;
			}

			this[procedure](_lairObject);
		}
	}

	function resetContainer( _container, _lairObject, _resetTime = true )
	{
		::Raids.Standard.setFlag(_container, false, _lairObject);
		if (_resetTime) this.resetContainerTime(_container, _lairObject);
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

		local edictDates = occupiedContainers.map(@(_container) ::Raids.Standard.getFlag(format("%sTime", _container), _lairObject)),
		edictDurations = occupiedContainers.map(@(_container) ::Raids.Standard.getFlag(format("%sDuration", _container), _lairObject));

		for( local i = 0; i < occupiedContainers.len(); i++ )
		{
			if (!edictDates[i])
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
};