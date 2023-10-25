local Raids = ::RPGR_Raids;
Raids.Edicts <-
{
    CycledEdicts =
    [
        "special.edict_of_agitation",
        "special.edict_of_impoverishment",
        "special.edict_of_opportunism"
    ],
    Factions =
    [
        ::Const.FactionType.Bandits,
        ::Const.FactionType.Barbarians,
        ::Const.FactionType.OrientalBandits
    ],
    Parameters =
    {
        DurationDays = 2,
    }

    function createEdict()
    {
        local edicts = ::IO.enumerateFiles("scripts/items/special/edicts");
        return ::new(edicts[::Math.rand(0, edicts.len() - 1)]);
    }

    function clearEdicts( _lair )
    {
        local containers = ["EdictContainerA", "EdictContainerB"];

        foreach( container in containers )
        {
            Raids.Standard.setFlag(container, false, _lair);
            Raids.Standard.setFlag(format("%sTime", container), false, _lair);
        }
    }

    function cycleEdicts( _lair )
    {
        foreach( edict in this.CycledEdicts ) this.emptyContainer(edict, _lair, true);
    }

    function emptyContainer( _edict, _lair, _filterActive = false )
    {
        local container = this.findEdict(_edict, _lair);

        if (!container)
        {
            return;
        }

        if (_filterActive && Raids.Standard.getFlag(format("%sTime", container)) != false)
        {
            return;
        }

        Raids.Standard.setFlag(container, false, _lair);
    }

    function executeAgitationProcedure( _lair )
    {
        Raids.Lairs.setAgitation(_lair, Raids.Lairs.Procedures.Increment);
    }

    function executeEdictProcedure( _flag, _lair )
    {
        local edict = this.getEdictName(_flag, _lair), procedure = format("execute%sProcedure", edict);

        if (!(procedure in this))
        {
            return;
        }

        this[procedure](_lair);
        Raids.Standard.setFlag(format("%sTime", _flag), false, _lair);
        this.cycleEdicts(_lair);
    }

    function executeDiminutionProcedure( _lair )
    {
        local resources = _lair.getResources(), newResources = resources - ::Math.floor(0.25 * resources);
        _lair.setResources(newResources);
        _lair.createDefenders();
    }

    function executeOpportunistProcedure( _lair )
    {
        Raids.Lairs.repopulateLairNamedLoot(_lair);
        this.cycleEdicts(_lair);
    }

    function findEdict( _ID, _lair, _filterActive = false )
    {
        if (_ID != "special.edict_of_agitation" && Raids.Standard.getFlag("Agitation", _lair) == Raids.Lairs.AgitationDescriptors.Relaxed)
        {
            return false;
        }

        local containers = ["EdictContainerA", "EdictContainerB"], container = false;

        foreach( flag in containers )
        {
            if (Raids.Standard.getFlag(flag, _lair) == _ID)
            {
                container = flag;
                break;
            }
        }

        if (!_filterActive || !Raids.Standard.getFlag(format("%sTime", container), _lair))
        {
            return container;
        }

        return false;
    }

    function getEdictName( _flag, _lair )
    {
        local culledString = "special.edict_of_", edictID = Raids.Standard.getFlag(_flag, _lair),
        edict = Raids.Standard.setCase(edictID.slice(culledString.len()), "toupper");
        return edict;
    }

    function getTooltipEntries( _lair )
    {
        local entryTemplate = {id = 20, type = "text", icon = "ui/icons/unknown_traits.png", text = "Edict: Vacant"},
        validContainers = this.getValidContainers(_lair);

        if (validContainers.len() == 0)
        {
            return [entryTemplate, entryTemplate];
        }

        local entries = [], isAgitated = Raids.Standard.getFlags("Agitation", _lair) != Raids.Lairs.AgitationDescriptors.Relaxed;

        foreach( flag in validContainers )
        {
            local entry = clone entryTemplate,
            edictTime = Raids.Standard.getFlag(format("%sTime", flag), _lair),
            isActive = (!edictTime || !isAgitated);
            entry.icon = isActive ? "ui/icons/scroll_01_b.png" : "ui/icons/scroll_01_sw.png";
            entry.text = format("Edict: %s (%s)", this.getEdictName(flag, _lair), isActive ? "Active" : isAgitated ? "Discovery" : "Inert");
            entries.push(entry);
        }

        if (entries.len() == 2)
        {
            return entries;
        }

        entries.push(entryTemplate);
        return entries;
    }

    function getValidContainers( _lair )
    {
        local validContainers = [],
        validityCheck = @(_flag) Raids.Standard.getFlag(_flag, _lair) != false && Raids.Standard.getFlag(format("%sTime", _flag), _lair) != false;
        if (validityCheck("EdictContainerA")) validContainers.push("EdictContainerA");
        if (validityCheck("EdictContainerB")) validContainers.push("EdictContainerB");
        return validContainers;
    }

    function updateEdicts( _lair )
    {
        local validContainers = this.getValidContainers(_lair);

        if (validContainers.len() == 0)
        {
            return;
        }

        local edictDates = validContainers.map(@(_flag) Raids.Standard.getFlag(format("%sTime", _flag), _lair));

        for( local i = 0; i < validContainers.len(); i++ )
        {
            if (!edictDates[i]) continue;
            if (::World.getTime().Days - edictDates[i] >= this.Parameters.DurationDays) this.executeEdictProcedure(validContainers[i], _lair);
        }
    }
};