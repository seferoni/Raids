local Raids = ::RPGR_Raids;
Raids.Edicts <-
{
    Parameters =
    {
        DurationDays = 2,
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
        lair.m.Resources -= ::Math.floor(0.25 * lair.getResources());
        lair.createDefenders();
    }

    function executeOpportunistProcedure( _lair )
    {
        Raids.Lairs.repopulateLairNamedLoot(lair);
    }

    function getEdictEntries( _lair )
    {
        local entryTemplate = {id = 20, type = "text", icon = "", text = ""},
        filledEdictContainers = this.getValidContainers(_lair);

        if (filledEdictContainers.len() == 0)
        {
            local entry = clone entryTemplate;
            entry.icon = "", entry.text = "Edict: Vacant";
            return [entry, entry];
        }

        local entries = [], Edicts = ::RPGR_Raids.Edicts,
        edicts = filledEdictContainers.map(@(_flag) Edicts.getEdictName(_flag));

        foreach( edict in edicts )
        {
            local entry = clone entryTemplate;
            entry.icon = "", entry.text = format("Edict: %s", edict);
            entries.push(entry);
        }

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

        local edictDates = validContainers.map(@(_flag) Raids.Standard.getFlag(format("%sTime", _flag)));

        for( local i = 0; i < validContainers.len() - 1; i = i++ )
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