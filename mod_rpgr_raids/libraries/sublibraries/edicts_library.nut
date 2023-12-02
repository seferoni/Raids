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
		ResourcesPrefactor = 0.001,
		SupplyCaravanDocumentChanceOffset = 35,
		WritingInstrumentsChance = 66
	},
	Parameters =
	{
		AbundanceCeiling = 3,
		AbundanceOffset = 1,
		DiminutionModifier = 0.90,
		MobilisationOffset = -37.5,
		ProspectingOffset = 5.0,
		RetentionOffset = -5.0
		StasisOffset = 7,
	}

	function addToHistory( _edictName, _lair )
	{
		local history = Raids.Standard.getFlag("EdictHistory", _lair),
		newHistory = format("%s%s", !history ? "" : format("%s, ", history), _edictName);
		Raids.Standard.setFlag("EdictHistory", newHistory, _lair);
	}

	function createEdict()
	{
		local edicts = ::IO.enumerateFiles("scripts/items/special/edicts");
		return ::new(edicts[::Math.rand(0, edicts.len() - 1)]);
	}

	function clearEdicts( _lair )
	{
		foreach( container in this.Containers )
		{
			this.resetContainer(container, _lair);
		}
	}

	function clearHistory( _lair )
	{
		Raids.Standard.setFlag("EdictHistory", false, _lair);
	}

	function createTooltipEntry( _lair, _iconPath, _edictName, _activityState )
	{
		local entry = {id = 20, type = "text"};
		entry.icon <- format("ui/icons/%s", _iconPath);
		entry.text <- format("Edict: %s (%s)", _edictName, _activityState);
		return entry;
	}

	function executeAgitationProcedure( _lair )
	{
		this.resetContainer(this.findEdict(this.getEdictID("Agitation"), _lair), _lair, false);
		Raids.Lairs.setAgitation(_lair, Raids.Lairs.Procedures.Increment);
	}

	function executeEdictProcedure( _container, _lair )
	{
		local edictID = Raids.Standard.getFlag(_container, _lair),
		edictName = this.getEdictName(edictID),
		procedure = format("execute%sProcedure", edictName);

		if (this.CycledEdicts.find(edictName) != null)
		{
			this.resetContainer(_container, _lair);
			this.addToHistory(edictName, _lair);
		}
		else
		{
			this.resetContainerTime(_container, _lair);
		}

		if (procedure in this)
		{
			this[procedure](_lair);
		}	

		if (this.InertEdicts.find(edictName) != null)
		{
			return;
		}

		if (::Math.rand(1, 100) > this.Internal.AgitationChance)
		{
			return;
		}

		if (Raids.Standard.getFlag("Agitation", _lair) != Raids.Lairs.AgitationDescriptors.Relaxed)
		{
			return;
		}

		Raids.Lairs.setAgitation(_lair, Raids.Lairs.Procedures.Increment);
	}

	function executeDiminutionProcedure( _lair )
	{
		local modifier = this.Parameters.DiminutionModifier - (this.Internal.ResourcesPrefactor * _lair.getResources());
		_lair.setResources(::Math.max(Raids.Standard.getFlag("BaseResources", _lair) / 2, ::Math.floor(modifier * _lair.getResources())));
		_lair.createDefenders();
	}

	function executeNullificationProcedure( _lair )
	{
		this.clearEdicts(_lair);
		this.clearHistory(_lair);
		Raids.Lairs.setResourcesByAgitation(_lair);
		_lair.createDefenders();
		_lair.setLootScaleBasedOnResources(_lair.getResources());
	}

	function executeOpportunismProcedure( _lair )
	{
		Raids.Lairs.repopulateNamedLoot(_lair);
	}

	function findEdict( _edictID, _lair, _filterActive = false )
	{
		local edictContainer = false;

		foreach( container in this.Containers )
		{
			if (Raids.Standard.getFlag(container, _lair) == _edictID)
			{
				edictContainer = container;
				break;
			}
		}

		if (!edictContainer)
		{
			return false;
		}

		if (!_filterActive || !Raids.Standard.getFlag(format("%sTime", edictContainer), _lair))
		{
			return edictContainer;
		}

		return false;
	}

	function findEdictInHistory( _edictName, _lair )
	{
		local history = Raids.Standard.getFlag("EdictHistory", _lair);

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

	function getAgitationDecayOffset( _lair )
	{
		local offset = 0,
		agitation = Raids.Standard.getFlag("Agitation", _lair);

		if (this.findEdict(this.getEdictID("Stasis"), _lair, true) != false)
		{
			offset += this.Parameters.StasisOffset * agitation;
		}

		return offset;
	}

	function getEdictID( _edictName )
	{
		local prependedString = "special.edict_of_",
		edictID = format("%s%s", prependedString,  Raids.Standard.setCase(_edictName, "tolower"));
		return edictID;
	}

	function getEdictName( _edictID )
	{
		local culledString = "special.edict_of_",
		edictName = Raids.Standard.setCase(_edictID.slice(culledString.len()), "toupper");
		return edictName;
	}

	function getHistoryEntry( _lair )
	{
		local history = Raids.Standard.colourWrap(Raids.Standard.getFlag("EdictHistory", _lair), "NegativeValue"),
		entry = {id = 20, type = "text", icon = "ui/icons/papers.png", text = history};
		return entry;
	}

	function getLegibilityEntry( _lair )
	{
		local entry = this.createTooltipEntry(_lair, "scroll_02_sw.png", "Legibility", "Discovery");
		return entry;
	}

	function getNamedLootChanceOffset( _lair, _depopulate = false )
	{
		local offset = 0.0, 
		agitation = Raids.Standard.getFlag("Agitation", _lair);

		if (_depopulate && this.findEdict(this.getEdictID("Retention"), _lair, true) != false)
		{
			offset = this.Parameters.RetentionOffset * agitation;
		}
		else if (this.findEdict(this.getEdictID("Prospecting"), _lair, true) != false)
		{
			offset = this.Parameters.ProspectingOffset * agitation;
		}

		return offset;
	}

	function getNonviableEntries( _lair )
	{
		local entries = [];

		if (this.findEdict(this.getEdictID("Legibility"), _lair) != false)
		{
			entries.push(this.getLegibilityEntry(_lair));
		}

		return entries;
	}

	function getPerspicuityEntry( _lair )
	{
		local entry = {id = 20, type = "text"},
		loot = _lair.getLoot().getItems(),
		count = 0;

		foreach( item in loot )
		{
			if (item != null && item.isItemType(::Const.Items.ItemType.Named)) count++;
		}

		entry.icon <- format("ui/icons/%s", count == 0 ? "cancel.png" : "special.png");
		entry.text <- Raids.Standard.colourWrap(format("Famed (%i)", count), format("%sValue", count == 0 ? "Negative" : "Positive"));
		return entry;
	}

	function getSpawnTimeOffset( _lair )
	{
		local offset = 0,
		agitation = Raids.Standard.getFlag("Agitation", _lair);

		if (this.findEdict(this.getEdictID("Mobilisation"), _lair, true) != false)
		{
			offset += this.Parameters.MobilisationOffset * agitation;
		}

		return offset;
	}

	function getSpecialEntries( _lair )
	{
		local entries = [];

		if (this.findEdict(this.getEdictID("Perspicuity"), _lair, true) != false)
		{
			entries.push(this.getPerspicuityEntry(_lair));
		}

		if (Raids.Standard.getFlag("EdictHistory", _lair) != false)
		{
			entries.push(this.getHistoryEntry(_lair));
		}

		return entries;
	}

	function getTreasureOffset( _lair )
	{
		if (!this.findEdictInHistory("Abundance", _lair))
		{
			return 0;
		}

		local offset = ::Math.min(this.Parameters.AbundanceCeiling, this.Parameters.AbundanceOffset * Raids.Standard.getFlag("Agitation", _lair));
		return offset;
	}

	function getTooltipEntries( _lair )
	{
		local entryTemplate = {id = 20, type = "text", icon = "ui/icons/unknown_traits.png", text = "Edict: Vacant"},
		entries = [], occupiedContainers = this.getOccupiedContainers(_lair);

		if (occupiedContainers.len() == 0)
		{
			entries.resize(this.Containers.len(), entryTemplate);
			entries.extend(this.getSpecialEntries(_lair));
			return entries;
		}

		foreach( container in occupiedContainers )
		{
			local inDiscovery = Raids.Standard.getFlag(format("%sTime", container), _lair) != false,
			edictName = this.getEdictName(Raids.Standard.getFlag(container, _lair)),
			iconPath = format("scroll_0%s.png", inDiscovery ? "2_sw" : "1_b"),
			activityState = inDiscovery ? "Discovery" : "Active";
			entries.push(this.createTooltipEntry(_lair, iconPath, edictName, activityState));
		}

		if (entries.len() < this.Containers.len())
		{
			local iterations = this.Containers.len() - entries.len();

			for( local i = 0; i < iterations; i++ )
			{
				entries.push(entryTemplate);
			}
		}

		entries.extend(this.getSpecialEntries(_lair));
		return entries;
	}

	function getOccupiedContainers( _lair )
	{
		local occupiedContainers = [],
		occupied = @(_container) Raids.Standard.getFlag(_container, _lair) != false;

		foreach( container in this.Containers )
		{
			if (occupied(container)) occupiedContainers.push(container);
		}

		return occupiedContainers;
	}

	function isLairViable( _lair )
	{
		if (!_lair.m.IsShowingBanner)
		{
			return false;
		}

		local Lairs = Raids.Lairs,
		factionType = ::World.FactionManager.getFaction(_lair.getFaction()).getType(),
		factions = this.findEdict(this.getEdictID("Legibility"), _lair, true) != false ? Lairs.Factions : this.Factions,
		viableFactions = factions.map(@(_factionName) Lairs.getFactionType(_factionName));

		if (viableFactions.find(factionType) != null)
		{
			return true;
		}

		return false;
	}

	function refreshEdicts( _lair )
	{
		local history = Raids.Standard.getFlag("EdictHistory", _lair);

		if (!history)
		{
			return;
		}

		local viableEdicts = this.CycledEdicts.filter(@(_index, _edictName) history.find(_edictName) != null);

		foreach( edictName in viableEdicts )
		{
			local procedure = format("execute%sProcedure", edictName);

			if (!(procedure in this))
			{
				continue;
			}

			this[procedure](_lair);
		}
	}

	function resetContainer( _container, _lair, _resetTime = true )
	{
		Raids.Standard.setFlag(_container, false, _lair);
		if (_resetTime) this.resetContainerTime(_container, _lair);
	}

	function resetContainerTime( _container, _lair )
	{
		Raids.Standard.setFlag(format("%sTime", _container), false, _lair);
	}

	function updateEdicts( _lair )
	{
		local occupiedContainers = this.getOccupiedContainers(_lair);

		if (occupiedContainers.len() == 0)
		{
			return;
		}

		local edictDates = occupiedContainers.map(@(_container) Raids.Standard.getFlag(format("%sTime", _container), _lair)),
		edictDurations = occupiedContainers.map(@(_container) Raids.Standard.getFlag(format("%sDuration", _container), _lair));

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

			this.executeEdictProcedure(occupiedContainers[i], _lair);
		}
	}
};