local Raids = ::RPGR_Raids;
Raids.Edicts <-
{
	Containers =
	[
		"EdictContainerA",
		"EdictContainerB",
		"EdictContainerC"
	],
	CycledEdicts =
	[
		"Abundance",
		"Diminution",
		"Opportunism"
	],
	Factions =
	[
		"Bandits",
		"OrientalBandits"
	],
	InertEdicts =
	[
		"Agitation",
		"Legibility"
	],
	Internal =
	{
		AgitationChance = 20,
		DirectoryPath = "scripts/items/special/edicts/",
		EdictSelectionSize = 3,
		ResourcesPrefactor = 0.001,
		WritingInstrumentsChance = 66
	},
	Parameters =
	{
		AbundanceCeiling = 3,
		AbundanceOffset = 1,
		DiminutionModifier = 0.90,
		MobilisationOffset = -150.0,
		ProspectingOffset = 5.0,
		RetentionOffset = -5.0,
		StasisOffset = 2
	},
	Tooltip =
	{
		Text = 
		{
			id = 20, 
			type = "text", 
			icon = "ui/icons/unknown_traits.png", 
			text = "Edict: Vacant"
		}
	}

	function addToHistory( _edictName, _lairObject )
	{
		local history = Raids.Standard.getFlag("EdictHistory", _lairObject),
		newHistory = format("%s%s", !history ? "" : format("%s, ", history), _edictName);
		Raids.Standard.setFlag("EdictHistory", newHistory, _lairObject);
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
		Raids.Standard.setFlag("EdictHistory", false, _lairObject);
	}

	function createTooltipEntry( _lairObject, _iconPath, _edictName, _activityState )
	{
		local entry = clone this.Tooltip.Text;
		entry.icon = format("ui/icons/%s", _iconPath);
		entry.text = format("Edict: %s (%s)", _edictName, _activityState);
		return entry;
	}

	function executeAgitationProcedure( _lairObject )
	{
		this.resetContainer(this.findEdict("Agitation", _lairObject), _lairObject, false);
		Raids.Lairs.setAgitation(_lairObject, Raids.Lairs.Procedures.Increment);
	}

	function executeEdictProcedure( _container, _lairObject )
	{
		local edictID = Raids.Standard.getFlag(_container, _lairObject),
		edictName = this.getEdictName(edictID),
		procedure = format("execute%sProcedure", edictName);

		if (this.CycledEdicts.find(edictName) != null)
		{
			this.resetContainer(_container, _lairObject);
			this.addToHistory(edictName, _lairObject);
		}
		else
		{
			this.resetContainerTime(_container, _lairObject);
		}

		local isAgitated = Raids.Standard.getFlag("Agitation", _lairObject) != Raids.Lairs.AgitationDescriptors.Relaxed,
		isInert = this.InertEdicts.find(edictName) != null;

		if (!isAgitated && !isInert && ::Math.rand(1, 100) <= this.Internal.AgitationChance)
		{
			Raids.Lairs.setAgitation(_lairObject, Raids.Lairs.Procedures.Increment);
		}

		if (!(procedure in this))
		{
			return;
		}

		this[procedure](_lairObject);
	}

	function executeDiminutionProcedure( _lairObject )
	{
		local modifier = this.Parameters.DiminutionModifier - (this.Internal.ResourcesPrefactor * _lairObject.getResources());
		_lairObject.setResources(::Math.max(Raids.Standard.getFlag("BaseResources", _lairObject) / 2, ::Math.floor(modifier * _lairObject.getResources())));
		_lairObject.createDefenders();
	}

	function executeNullificationProcedure( _lairObject )
	{
		this.clearEdicts(_lairObject);
		this.clearHistory(_lairObject);
		Raids.Lairs.setResourcesByAgitation(_lairObject);
		_lairObject.createDefenders();
		_lairObject.setLootScaleBasedOnResources(_lairObject.getResources());
	}

	function executeOpportunismProcedure( _lairObject )
	{
		Raids.Lairs.repopulateNamedLoot(_lairObject);
	}

	function findEdict( _edictName, _lairObject, _filterActive = false )
	{
		local edictID = this.getEdictID(_edictName), edictContainer = false;

		foreach( container in this.Containers )
		{
			if (Raids.Standard.getFlag(container, _lairObject) == edictID)
			{
				edictContainer = container;
				break;
			}
		}

		if (!edictContainer)
		{
			return false;
		}

		if (!_filterActive || !Raids.Standard.getFlag(format("%sTime", edictContainer), _lairObject))
		{
			return edictContainer;
		}

		return false;
	}

	function findEdictInHistory( _edictName, _lairObject )
	{
		local history = Raids.Standard.getFlag("EdictHistory", _lairObject);

		if (!history)
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
			offset = this.Parameters.StasisOffset * (Raids.Standard.getFlag("Agitation", _lairObject) - 1);
		}

		return offset;
	}

	function getContainerEntries( _lairObject )
	{
		# Prepare variables in local environment.
		local entries = [], 
		occupiedContainers = this.getOccupiedContainers(_lairObject);

		# Handle case where all containers are vacant.
		if (occupiedContainers.len() == 0)
		{
			entries.resize(this.Containers.len(), this.Tooltip.Text);
			entries.extend(this.getSpecialEntries(_lairObject));
			return entries;
		}

		# Create entries for occupied containers.
		foreach( container in occupiedContainers )
		{
			# Prepare variables in local environment.
			local inDiscovery = Raids.Standard.getFlag(format("%sTime", container), _lairObject) != false,
			edictName = this.getEdictName(Raids.Standard.getFlag(container, _lairObject));

			# Create tooltip entry.
			iconPath = format("scroll_0%s.png", inDiscovery ? "2_sw" : "1_b"), activityState = inDiscovery ? "Discovery" : "Active";
			entries.push(this.createTooltipEntry(_lairObject, iconPath, edictName, activityState));
		}

		# Create entries for vacant containers.
		if (entries.len() < this.Containers.len())
		{
			local iterations = this.Containers.len() - entries.len();

			for( local i = 0; i < iterations; i++ )
			{
				entries.push(this.Tooltip.Text);
			}
		}

		return entries;
	}

	function getEdictFileName( _edictName )
	{
		local prependedString = format("%s%s", this.Internal.DirectoryPath, "edict_of_"),
		edictFileName = format("%s%s", prependedString, Raids.Standard.setCase(_edictName, "tolower"));
		return edictFileName;
	}

	function getEdictFiles()
	{
		return ::IO.enumerateFiles(this.Internal.DirectoryPath);
	}

	function getEdictID( _edictName )
	{
		local prependedString = "special.edict_of_",
		edictID = format("%s%s", prependedString,  Raids.Standard.setCase(_edictName, "tolower"));
		return edictID;
	}

	function getEdictName( _edictID, _isFileName = false )
	{
		local culledString = _isFileName ? format("%s%s", this.Internal.DirectoryPath, "edict_of_") : "special.edict_of_",
		edictName = Raids.Standard.setCase(_edictID.slice(culledString.len()), "toupper");
		return edictName;
	}

	function getFamedItemEntry( _lairObject )
	{
		local entry = clone this.Tooltip.Text,
		loot = _lairObject.getLoot().getItems(),
		count = 0;

		foreach( item in loot )
		{
			if (item != null && item.isItemType(::Const.Items.ItemType.Named)) count++;
		}

		entry.icon = format("ui/icons/%s", count == 0 ? "cancel.png" : "special.png");
		entry.text = Raids.Standard.colourWrap(format("Famed (%i)", count), format("%sValue", count == 0 ? "Negative" : "Positive"));
		return entry;
	}

	function getHistoryEntry( _lairObject )
	{
		local history = Raids.Standard.colourWrap(Raids.Standard.getFlag("EdictHistory", _lairObject), "NegativeValue"),
		entry = {id = 20, type = "text", icon = "ui/icons/papers.png", text = history};
		return entry;
	}

	function getLegibilityEntry( _lairObject )
	{
		local entry = this.createTooltipEntry(_lairObject, "scroll_02_sw.png", "Legibility", "Discovery");
		return entry;
	}

	function getNamedLootChanceOffset( _lairObject, _depopulate = false )
	{
		local offset = 0.0,
		agitation = Raids.Standard.getFlag("Agitation", _lairObject);

		if (_depopulate && this.findEdict("Retention", _lairObject, true) != false)
		{
			offset = this.Parameters.RetentionOffset * agitation;
		}
		else if (this.findEdict("Prospecting", _lairObject, true) != false)
		{
			offset = this.Parameters.ProspectingOffset * agitation;
		}

		return offset;
	}

	function getNonviableEntries( _lairObject )
	{
		local entries = [];

		if (this.findEdict("Legibility", _lairObject) != false)
		{
			entries.push(this.getLegibilityEntry(_lairObject));
		}

		return entries;
	}

	function getSpawnTimeOffset( _lairObject )
	{
		local offset = 0.0;

		if (this.findEdict("Mobilisation", _lairObject, true) != false)
		{
			offset = this.Parameters.MobilisationOffset;
		}

		return offset;
	}

	function getSpecialEntries( _lairObject )
	{
		local entries = [this.getFamedItemEntry(_lairObject)];

		if (Raids.Standard.getFlag("EdictHistory", _lairObject) != false)
		{
			entries.push(this.getHistoryEntry(_lairObject));
		}

		return entries;
	}

	function getTreasureOffset( _lairObject )
	{
		local offset = 0;

		if (this.findEdictInHistory("Abundance", _lairObject) != false)
		{
			offset = ::Math.min(this.Parameters.AbundanceCeiling, this.Parameters.AbundanceOffset * Raids.Standard.getFlag("Agitation", _lairObject));
		}

		return offset;
	}

	function getTooltipEntries( _lairObject )
	{
		local entries = this.getContainerEntries(_lairObject);
		entries.extend(this.getSpecialEntries(_lairObject));
		return entries;
	}

	function getOccupiedContainers( _lairObject )
	{
		local occupiedContainers = [],
		occupied = @(_container) Raids.Standard.getFlag(_container, _lairObject) != false;

		foreach( container in this.Containers )
		{
			if (occupied(container)) occupiedContainers.push(container);
		}

		return occupiedContainers;
	}

	function isLairViable( _lairObject )
	{
		if (!_lairObject.m.IsShowingBanner)
		{
			return false;
		}

		local Lairs = Raids.Lairs,
		factionType = ::World.FactionManager.getFaction(_lairObject.getFaction()).getType(),
		factions = this.findEdict("Legibility", _lairObject, true) != false ? Lairs.Factions : this.Factions,
		viableFactions = factions.map(@(_factionName) Lairs.getFactionType(_factionName));

		if (viableFactions.find(factionType) != null)
		{
			return true;
		}

		return false;
	}

	function refreshEdicts( _lairObject )
	{
		if (!Raids.Standard.getFlag("EdictHistory", _lairObject))
		{
			return;
		}

		local Edicts = this, viableEdicts = this.CycledEdicts.filter(@(_index, _edictName) Edicts.findEdictInHistory(_edictName, _lairObject));

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
		Raids.Standard.setFlag(_container, false, _lairObject);
		if (_resetTime) this.resetContainerTime(_container, _lairObject);
	}

	function resetContainerTime( _container, _lairObject )
	{
		Raids.Standard.setFlag(format("%sTime", _container), false, _lairObject);
	}

	function updateEdicts( _lairObject )
	{
		local occupiedContainers = this.getOccupiedContainers(_lairObject);

		if (occupiedContainers.len() == 0)
		{
			return;
		}

		local edictDates = occupiedContainers.map(@(_container) Raids.Standard.getFlag(format("%sTime", _container), _lairObject)),
		edictDurations = occupiedContainers.map(@(_container) Raids.Standard.getFlag(format("%sDuration", _container), _lairObject));

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