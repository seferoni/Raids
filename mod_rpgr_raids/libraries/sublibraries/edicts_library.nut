local Raids = ::RPGR_Raids;
Raids.Edicts <-
{
    Containers =
    [
        "EdictContainerA",
        "EdictContainerB"
    ]
    CycledEdicts =
    [
        "Abundance",
        "Diminution",
        "Opportunism",
        "Retention"
    ],
    Factions =
    [
        ::Const.FactionType.Bandits,
        ::Const.FactionType.OrientalBandits
    ],
    Internal =
    {
        AgitationPrefactor = 0.1,
        ResourcesPrefactor = 0.001,
        SupplyCaravanDocumentChanceOffset = 35,
        WritingInstrumentsChance = 66
    },
    Parameters =
    {
        AbundanceOffset = 0.08,
        DiminutionModifier = 0.90,
        ProspectingOffset = 5.0,
        ProvocationModifier = 2.1,
        RetentionOffset = -5
    }

    function addToHistory( _edictName, _lair )
    {   // FIXME: whitespace between commas
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

    function executeAbundanceProcedure( _lair )
    {
        local offset = this.Parameters.AbundanceOffset * Raids.Standard.getFlag("Agitation", _lair);
        _lair.m.LootScale = ::Math.min(1.0, _lair.m.LootScale + offset);
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

        if (!(procedure in this))
        {
            return;
        }

        this[procedure](_lair);
    }

    function executeDiminutionProcedure( _lair )
    {   // TODO: check if garrison is appropriately weakened
        local modifier = this.Parameters.DiminutionModifier - (this.Internal.ResourcesPrefactor * _lair.getResources());
        _lair.setResources(::Math.max(Raids.Standard.getFlag("BaseResources", _lair) / 2, modifier * _lair.getResources()));
        _lair.createDefenders();
    }

    function executeNullificationProcedure( _lair )
    {
        this.clearEdicts(_lair);
    }

    function executeOpportunistProcedure( _lair )
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

    function findEdictInHistory( _edictName, _lair)
    {
        local history = Raids.Standard.getFlag("EdictHistory", _lair);

        if (!history)
        {
            return false;
        }

        if (history.find(_edictName))
        {
            return true;
        }

        return false;
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

    function getLootScaleOffset( _lair )
    {
        if (!this.findEdict(this.getEdictID("Abundance"), _lair, true))
        {
            return 0;
        }

        local offset = this.Parameters.AbundanceOffset * Raids.Standard.getFlag("Agitation", _lair);
        return offset;
    }

    function getNamedLootChanceOffset( _lair, _depopulate = false )
    {
        local agitation = Raids.Standard.getFlag("Agitation", _lair);

        if (_depopulate && this.findEdict(this.getEdictID("Abeyance"), _lair, true) != false)
        {
            return this.Parameters.RetentionOffset * agitation;
        }

        if (this.findEdict(this.getEdictID("Prospecting"), _lair, true) != false)
        {
            return this.Parameters.ProspectingOffset * agitation;
        }

        return 0.0;
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

    function getResourceModifier( _lair )
    {
        if (!this.findEdict(this.getEdictID("Provocation"), _lair, true))
        {
            return 1.0;
        }

        local modifier = this.Parameters.ProvocationModifier + (3.0 * this.Internal.AgitationPrefactor * Raids.Standard.getFlag("Agitation", _lair) - 1);
        return modifier;
    }

    function getTooltipEntries( _lair )
    {
        local entryTemplate = {id = 20, type = "text", icon = "ui/icons/unknown_traits.png", text = "Edict: Vacant"},
        entries = [], occupiedContainers = this.getOccupiedContainers(_lair);

        if (occupiedContainers.len() == 0)
        {
            entries.extend([entryTemplate, entryTemplate]);
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

        if (entries.len() < 2)
        {
            entries.push(entryTemplate);
        }

        entries.extend(this.getSpecialEntries(_lair));
        return entries;
    }

    function getOccupiedContainers( _lair )
    {
        local occupiedContainers = [],
        occupancyCheck = @(_container) Raids.Standard.getFlag(_container, _lair) != false;
        if (occupancyCheck("EdictContainerA")) occupiedContainers.push("EdictContainerA");
        if (occupancyCheck("EdictContainerB")) occupiedContainers.push("EdictContainerB");
        return occupiedContainers;
    }

    function isLairViable( _lair )
    {
        local factionType = ::World.FactionManager.getFaction(_lair.getFaction()).getType(),
        factions = this.findEdict(this.getEdictID("Legibility"), _lair, true) != false ? Raids.Lairs.Factions : this.Factions;

        if (factions.find(factionType) != null)
        {
            return true;
        }

        return false;
    }

    function refreshEdicts( _lair )
    {   // FIXME: need ways to prevent players from applying a boatload of edicts at Relaxed
        // FIXME: need to prevent special edicts from firing multiple times
        local history = Raids.Standard.getFlag("EdictHistory", _lair),
        viableEdicts = this.CycledEdicts.filter(@(_index, _edictID) history.find(_edictID) != null);

        foreach( edictID in viableEdicts )
        {
            local edictName = this.getEdictName(edictID),
            procedure = format("execute%sProcedure", edictName);
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

        local edicts = occupiedContainers.map(@(_container) Raids.Standard.getFlag(_container, _lair)),
        edictDates = occupiedContainers.map(@(_container) Raids.Standard.getFlag(format("%sTime", _container), _lair)),
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