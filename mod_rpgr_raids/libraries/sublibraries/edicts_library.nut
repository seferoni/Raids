local Raids = ::RPGR_Raids;
Raids.Edicts <-
{
    Parameters =
    {
        DurationDays = 2,
    }

    function createEdict()
    {
        local edicts = ::IO.enumerateFiles("scripts/items/special/edicts");
        return ::new(edicts[::Math.rand(0, edicts.len() - 1)]);
    }

    function executeAgitationProcedure( _lair )
    {
        Raids.Lairs.agitateViableLairs([_lair]);
    }

    function executeEdictProcedure( _flag, _lair )
    {
        local edict = this.getEdictName(_flag);
        this[format("execute%sProcedure", edict)](_lair);
        Raids.Standard.setFlag(format("%sTime", _flag), false, _lair);
    }

    function executeImpoverishmentProcedure( _lair )
    {
        _lair.m.Resources -= ::Math.floor(0.25 * _lair.getResources());
        _lair.createDefenders();
    }

    function executeOpportunistProcedure( _lair )
    {
        Raids.Lairs.repopulateLairNamedLoot(_lair);
    }

    function findEdict( _ID, _lair )
    {
        local containers = ["EdictContainerA", "EdictContainerB"];

        foreach( flag in containers )
        {
            if (Raids.Standard.getFlag(flag, _lair) == _ID) return flag;
        }

        return null;
    }

    function getEdictEntries( _lair )
    {
        local entryTemplate = {id = 20, type = "text", icon = "ui/icons/unknown_traits.png", text = "Edict: Vacant"},
        validContainers = this.getValidContainers(_lair);

        if (validContainers.len() == 0)
        {
            return [entryTemplate, entryTemplate];
        }

        local entries = [];

        foreach( flag in validContainers )
        {
            local entry = clone entryTemplate;
            entry.icon = "ui/icons/scroll_01_b.png";
            entry.text = format("Edict: %s (%s)", Raids.Edicts.getEdictName(flag), Raids.Standard.getFlag(format("%sTime", flag)) != false ? "Discovery" : "Active");
            entries.push(entry);
        }

        if (entries.len() == 2)
        {
            return entries;
        }

        entries.push(entryTemplate);
        return entries;
    }

    function getEdictName( _flag )
    {
        local culledString = "special.edict_of",
        edict = Raids.Standard.setCase(_flag.slice(culledString.len()), "toupper");
        return edict;
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
            if (::World.getTime().Days - edictDates[i] >= this.Parameters.DurationDays) this.executeEdictProcedure(validContainers[i], _lair);
        }
    }

    function getValidContainers( _lair )
    {
        local validContainers = [],
        validityCheck = @(_flag) Raids.Standard.getFlag(_flag, _lair) != false && Raids.Standard.getFlag(format("%sTime", _flag), _lair) != false;
        if (validityCheck("EdictContainerA")) validContainers.push("EdictContainerA");
        if (validityCheck("EdictContainerB")) validContainers.push("EdictContainerB");
        return validContainers;
    }
};