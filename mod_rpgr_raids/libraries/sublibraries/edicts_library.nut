local Raids = ::RPGR_Raids;
Raids.Edicts <-
{   // TODO: evaluate temporary edict behaviour operating when inert DONE
    // FIXME: after using a temporary edict and permanent edict on a lair, no new edicts apply POSSIBLE FIX
    AgnosticEdicts =
    [
        "special.edict_of_agitation",
        "special.edict_of_legibility",
        "special.edict_of_nullification"
    ],
    Containers =
    [
        "EdictContainerA",
        "EdictContainerB"
    ]
    CycledEdicts =
    [
        "special.edict_of_abstention",
        "special.edict_of_agitation",
        "special.edict_of_diminution",
        "special.edict_of_opportunism"
    ],
    Factions =
    [
        ::Const.FactionType.Bandits,
        ::Const.FactionType.OrientalBandits
    ],
    Parameters =
    {
        AbeyanceOffset = -20,
        AbundanceOffset = 0.25,
        DurationDays = 2,
        DiminutionModifier = 0.75,
        ProspectingOffset = 10,
        ProvocationModifier = 2.5
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

    function createTooltipEntry( _lair, _iconPath, _edictName, _activityState )
    {
        local entry = {id = 20, type = "text"};
        entry.icon <- format("ui/icons/%s", _iconPath);
        entry.text <- format("Edict: %s (%s)", _edictName, _activityState);
        return entry;
    }

    function executeAbstentionProcedure( _lair )
    {
        _lair.setLastSpawnTimeToNow();
        local settlement = Raids.Shared.getSettlementClosestTo(_lair.getTile());

        if (settlement.getSituationByID("situation.safe_roads") == null)
        {
            settlement.addSituation(::new("scripts/entity/world/settlements/situations/safe_roads_situation"));
        }
    }

    function executeAbundanceProcedure( _lair )
    {
        _lair.m.LootScale = ::Math.min(1.0, _lair.m.LootScale + this.Parameters.AbundanceOffset);
    }

    function executeAgitationProcedure( _lair )
    {
        Raids.Lairs.setAgitation(_lair, Raids.Lairs.Procedures.Increment);
    }

    function executeEdictProcedure( _container, _lair )
    {
        local edict = Raids.Standard.getFlag(_container, _lair),
        edictName = this.getEdictName(edict, _lair),
        procedure = format("execute%sProcedure", edictName);

        if (this.CycledEdicts.find(edict) != null)
        {
            this.resetContainer(_container, _lair);
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
    {
        _lair.setResources(this.Parameters.DiminutionModifier * _lair.getResources());
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

    function findEdict( _ID, _lair, _filterActive = false )
    {
        if (this.isEdictInert(_ID, _lair))
        {
            return false;
        }

        local edictContainer = false;

        foreach( container in this.Containers )
        {
            if (Raids.Standard.getFlag(container, _lair) == _ID)
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

    function getEdictName( _ID, _lair )
    {
        local culledString = "special.edict_of_",
        edictName = Raids.Standard.setCase(_ID.slice(culledString.len()), "toupper");
        return edictName;
    }

    function getLegibilityEntry( _lair )
    {
        local entry = this.createTooltipEntry(_lair, "scroll_02_sw.png", "Legibility", "Discovery");
        return entry;
    }

    function getLootScaleOffset( _lair )
    {
        return this.findEdict("special.edict_of_abundance", _lair, true) != false ? this.Parameters.AbundanceOffset : 0.0;
    }

    function getNamedLootChanceOffset( _lair, _depopulate = false )
    {
        if (_depopulate && this.findEdict("special.edict_of_abeyance", _lair, true) != false)
        {
            return this.Parameters.AbeyanceOffset;
        }

        if (this.findEdict("special_edict_of_prospecting", _lair, true) != false)
        {
            return this.Parameters.ProspectingOffset;
        }

        return 0.0;
    }

    function getNonviableEntries( _lair )
    {
        local entries = [];

        if (this.findEdict("special.edict_of_legibility", _lair) != false)
        {
            entries.push(this.getLegibilityEntry(_lair));
        } 

        return entries;
    }

    function getPerspicuityEntry( _lair )
    {
        local entry = {id = 20, type = "text"},
        count = 0;

        foreach( item in _lair.getLoot() )
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

        if (this.findEdict("special.edict_of_perspicuity", _lair, true) != false)
        {
            entries.push(this.getPerspicuityEntry(_lair));
        }
        
        return entries;
    }

    function getResourceModifier( _lair )
    {
        return this.findEdict("special.edict_of_provocation", _lair, true) != false ? this.Parameters.ProvocationModifier : 1.0;
    }

    function getTooltipEntries( _lair )
    {   // TODO: edicts never leave discovery state (test with Abundance)
        local entryTemplate = {id = 20, type = "text", icon = "ui/icons/unknown_traits.png", text = "Edict: Vacant"},
        occupiedContainers = this.getOccupiedContainers(_lair);

        if (occupiedContainers.len() == 0)
        {
            return [entryTemplate, entryTemplate];
        }

        local entries = [], isAgitated = Raids.Standard.getFlag("Agitation", _lair) != Raids.Lairs.AgitationDescriptors.Relaxed;

        foreach( container in occupiedContainers )
        {
            local inDiscovery = Raids.Standard.getFlag(format("%sTime", container), _lair) != false,
            isActive = (!inDiscovery && isAgitated),
            iconPath = isActive ? "scroll_01_b.png" : inDiscovery ? "scroll_02_sw.png" : "scroll_01_sw.png",
            edictName = this.getEdictName(Raids.Standard.getFlag(container, _lair), _lair),
            activityState = isActive ? "Active" : inDiscovery ? "Discovery" : "Inert";
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

    function isEdictInert( _ID, _lair )
    {
        if (this.AgnosticEdicts.find(_ID) == null && Raids.Standard.getFlag("Agitation", _lair) == Raids.Lairs.AgitationDescriptors.Relaxed)
        {
            return true;
        }

        return false;
    }

    function isLairViable( _lair )
    {
        local factionType = ::World.FactionManager.getFaction(_lair.getFaction()).getType(),
        factions = this.findEdict("special.edict_of_legibility", _lair, true) != false ? Raids.Lairs.Factions : this.Factions;

        if (factions.find(factionType) != null)
        {
            return true;
        }

        return false;
    }

    function resetContainer( _container, _lair )
    {
        Raids.Standard.setFlag(_container, false, _lair);
        this.resetContainerTime(_container, _lair);
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

        local edicts = occupiedContainers.map(@(_container) Raids.Standard.getFlag(_container, _lair));
        local edictDates = occupiedContainers.map(@(_container) Raids.Standard.getFlag(format("%sTime", _container), _lair));

        for( local i = 0; i < occupiedContainers.len(); i++ )
        {
            if (this.isEdictInert(edicts[i], _lair)) continue; // FIXME: this prevents edicts from entering Inert from Discovery
            if (!edictDates[i]) continue;
            if (::World.getTime().Days - edictDates[i] >= this.Parameters.DurationDays) this.executeEdictProcedure(occupiedContainers[i], _lair);
        }
    }
};