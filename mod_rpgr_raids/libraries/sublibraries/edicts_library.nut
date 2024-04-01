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
		"Barbarians",
		"OrientalBandits",
		"Zombies"
	],
	Internal =
	{
		DirectoryPath = "scripts/items/special/edicts/",
		EdictSelectionSize = 3,
		ResourcesPrefactor = 0.001,
		WritingInstrumentsChance = 66
	},
	Overrides = 
	[
		"location.undead_crypt"
	],
	Parameters =
	{
		AbundanceCeiling = 3,
		AbundanceOffset = 1,
		DiminutionModifier = 0.9,
		DiminutionModifierFloor = 0.5,
		DiminutionResourcesMinimum = 75,
		ProspectingOffset = 8.0,
		StasisOffset = 1
	},
	Tooltip =
	{
		Icons =
		{
			Contracted =
			{
				Active = "scroll_01_b.png",
				Discovery = "scroll_02_sw.png"
			},
			NamedEmpty = "ui/icons/cancel.png",
			NamedPresent = "ui/icons/special.png",
			History = "ui/icons/papers.png"
		},
		Template =
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

	function createHistoryEntry( _lairObject )
	{
		local history = Raids.Standard.colourWrap(Raids.Standard.getFlag("EdictHistory", _lairObject), Raids.Standard.Colour.Red),
		entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.History;
		entry.text = history;
		return entry;
	}

	function createTooltipEntry( _lairObject, _iconPath, _edictName, _activityState )
	{
		local entry = clone this.Tooltip.Template;
		entry.icon = format("ui/icons/%s", _iconPath);
		entry.text = format("Edict: %s (%s)", _edictName, _activityState);
		return entry;
	}

	function executeAgitationProcedure( _lairObject )
	{
		this.resetContainer(this.findEdict("Agitation", _lairObject), _lairObject, false);
		Raids.Lairs.setAgitation(_lairObject, Raids.Lairs.Procedures.Increment);
	}

	function executeDiminutionProcedure( _lairObject )
	{	// TODO: diminution needs to be rewritten. it should simply remove the toughest troops?
		# Calculate new resources, ensuring that the acquired resources value does not fall below the lowest base lair resources value in the game.
		local newResources = ::Math.max(this.Parameters.DiminutionResourcesMinimum, _lairObject.getResources() * this.getResourcesModifier(_lairObject));
		
		# Set new resources value.
		Raids.Lairs.setResources(_lairObject, newResources);

		Raids.Lairs.Defenders.createDefenders(_lairObject, true); // TODO: this is a problem. diminution reduces actual resources, whereas 

		local agitation = Raids.Standard.getFlag("Agitation", _lairObject);

		
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
		Raids.Lairs.updateProperties(_lairObject);
	}

	function executeOpportunismProcedure( _lairObject )
	{
		Raids.Lairs.repopulateNamedLoot(_lairObject);
	}

	function findEdict( _edictName, _lairObject, _filterActive = false )
	{
		local edictContainer = false,
		edictID = this.getEdictID(_edictName);

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
		local entries = [],
		occupiedContainers = this.getOccupiedContainers(_lairObject);

		# Handle case where all containers are vacant.
		if (occupiedContainers.len() == 0)
		{
			entries.resize(this.Containers.len(), this.Tooltip.Template);
			return entries;
		}

		# Create entries for occupied containers.
		foreach( container in occupiedContainers )
		{
			# Prepare variables in local environment.
			local inDiscovery = Raids.Standard.getFlag(format("%sTime", container), _lairObject) != false,
			edictName = this.getEdictName(Raids.Standard.getFlag(container, _lairObject));

			# Create tooltip entry.
			local iconPath = this.Tooltip.Icons.Contracted[inDiscovery ? "Discovery" : "Active"],
			activityState = inDiscovery ? "Discovery" : "Active";
			entries.push(this.createTooltipEntry(_lairObject, iconPath, edictName, activityState));
		}

		# Create entries for vacant containers.
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

	function getLegibilityEntry( _lairObject )
	{
		local entry = this.createTooltipEntry(_lairObject, this.Tooltip.Icons.Contracted.Discovery, "Legibility", "Discovery");
		return entry;
	}

	function getNamedLootChanceOffset( _lairObject )
	{
		local offset = 0.0,
		agitation = Raids.Standard.getFlag("Agitation", _lairObject);

		if (this.findEdict("Prospecting", _lairObject, true) != false)
		{
			offset = this.Parameters.ProspectingOffset * agitation;
		}

		return offset;
	}

	function getNamedLootEntry( _lairObject )
	{
		local entry = clone this.Tooltip.Template,
		count = 0;

		# Get naive named loot chance.
		local naiveNamedLootChance = Raids.Lairs.getNamedLootChance(_lairObject);

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
		local fragmentA = Raids.Standard.colourWrap(format("Famed (%i)", count), Raids.Standard.Colour[count == 0 ? "Red" : "Green"]);

		# Assign text fragment corresponding to current named loot chance.
		local fragmentB = Raids.Standard.colourWrap(format("%i%%", namedLootChance), Raids.Standard.Colour.Green);
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
		local occupiedContainers = [],
		occupied = @(_container) Raids.Standard.getFlag(_container, _lairObject) != false;

		foreach( container in this.Containers )
		{
			if (occupied(container)) occupiedContainers.push(container);
		}

		return occupiedContainers;
	}

	function getResourcesModifier( _lairObject )
	{
		local modifier = this.Parameters.DiminutionModifier - (this.Internal.ResourcesPrefactor * _lairObject.getResources());
		return ::Math.maxf(this.Parameters.DiminutionModifierFloor, modifier);
	}

	function getSpecialEntries( _lairObject )
	{
		local entries = [];

		if (Raids.Standard.getSetting("ShowNamedLootEntry"))
		{
			entries.push(this.getNamedLootEntry(_lairObject));
		}

		if (Raids.Standard.getFlag("EdictHistory", _lairObject) != false)
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

	function isLairViable( _lairObject )
	{
		if (!_lairObject.m.IsShowingBanner)
		{
			return false;
		}
		
		# Retrieve faction type from faction manager.
		local factionType = ::World.FactionManager.getFaction(_lairObject.getFaction()).getType();

		# If an Edict of Legibility is not present, revert to native Edict-viable faction pool.
		local factions = this.findEdict("Legibility", _lairObject, true) != false ? Raids.Lairs.Factions : this.Factions;

		# Retrieve corresponding faction types from the ::Const table.
		local viableFactions = factions.map(@(_factionName) Raids.Lairs.getFactionType(_factionName));

		if (viableFactions.find(factionType) != null)
		{
			return true;
		}

		if (this.Overrides.find(_lairObject.getTypeID()) != null)
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

		local viableEdicts = this.CycledEdicts.filter(@(_index, _edictName) Raids.Edicts.findEdictInHistory(_edictName, _lairObject));

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