::RPGR_Raids <-
{
    ID = "mod_rpgr_raids",
    Name = "RPG Rebalance - Raids",
    Version = "1.0.0",
    AgitationDescriptors =
    {
        Relaxed = 1,
        Cautious = 2,
        Vigilant = 3,
        Desperate = 4
    },
    CaravanWealthDescriptors =
    {
        Impoverished = 1,
        Deprived = 2,
        Prosperous = 3,
        Opulent = 4
    },
    CaravanCargoDescriptors =
    {
        Rations = 1,
        Trade = 2,
        Assortment = 3,
        Oddities = 4
    },
    CampaignModifiers =
    {
        CaravanRareAndAboveChance = 1,
        FamedChanceOnCampSpawn = 30,
        MaximumDistanceToAgitate = 15
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    },
    Severity =
    {
        Unscathed = 0,
        Looted = 1,
        Sacked = 2
    }

    function createMundaneCaravanCargo( _folderPath, _caravanWealth, _isAssorted )
    {
        local cargo = [];
        local assortedGoods = ["ammo_item", "medicine_item", "armor_parts_item"];
        local iterations = ::Math.rand(1, _caravanWealth);

        if (_isAssorted)
        {
            for( local i = 0; i != iterations; i = ++i )
            {
                cargo.push(::new("scripts/items/" + _folderPath + assortedGoods[::Math.rand(0, assortedGoods.len() - 1)]));
            }

            return cargo;
        }

        local exclusionList = ["strange_meat_item", "fermented_unhold_heart_item"];
        exclusionList.extend(assortedGoods);
        local scriptFiles = ::IO.enumerateFiles("scripts/items/" + _folderPath);

        foreach( excludedFile in exclusionList )
        {
            local index = scriptFiles.find(excludedFile);

            if (index != null)
            {
                ::logInfo("Removed " + excludedFile + " from supply pool");
                scriptFiles.remove(index);
            }
        }

        for( local i = 0; i != iterations; i = ++i )
        {
            cargo.push(::new(scriptFiles[::Math.rand(0, scriptFiles.len() - 1)]));
        }

        return cargo;
    }

    function createNamedCaravanCargo( _caravanWealth )
    { // TODO: finish this
        local cargo = [];
        return cargo;
    }

    function getDescriptor( _valueToMatch, _referenceTable )
    {
        foreach( descriptor, value in _referenceTable )
        {
            if (value == _valueToMatch)
            {
                return descriptor;
            }
        }
    }

    function getSeverityScore( _settlement )
    {
        local score = 0.0;
        local smallestIncrement = 1.0;
        local synergisticSituations =
        [
            "situation.ambushed_trade_routes",
            "situation.greenskins",
            "situation.disappearing_villagers",
            "situation.conquered",
            "situation.warehouse_burned_down",
            "situation.drought"
        ];
        local antagonisticSituations =
        [
            "situation.well_supplied",
            "situation.good_harvest",
            "situation.safe_roads",
            "situation.mustering_troops"
        ];
        local activeContract = ::World.Contracts.getActiveContract();

        if (activeContract != null && activeContract.isTileUsed(_settlement.getTile()))
        {
            return this.Severity.Unscathed;
        }

        switch (_settlement.getSize())
        {
            case 3:
                score += smallestIncrement;
            case 2:
                score += smallestIncrement;
            case 1:
                break;
            default:
                ::logError("Settlement size indeterminate.");
        }

        foreach( situation in synergisticSituations )
        {
            if (_settlement.getSituationByID(situation) != null)
            {
                score += smallestIncrement;
            }
        }

        foreach( situation in antagonisticSituations )
        {
            if (_settlement.getSituationByID(situation) != null)
            {
                score -= smallestIncrement;
            }
        }

        if (_settlement.isMilitary())
        {
            score -= smallestIncrement;
        }

        if (_settlement.isIsolated() || _settlement.isIsolatedFromRoads() || _settlement.isCoastal())
        {
            score += smallestIncrement;
        }

        ::logInfo(_settlement.getName() + " was calculated to have a severity score of " + score + ".");
        return score;
    }

    function isFactionViable( _faction )
    {
        if (_faction == null)
        {
            return false;
        }

        local exclusionList = [::Const.FactionType.Beasts, ::Const.FactionType.Settlement, ::Const.FactionType.NobleHouse, ::Const.FactionType.Orcs];
        local factionType = _faction.getType();

        foreach( excludedFaction in exclusionList )
        {
            if (factionType == excludedFaction)
            {
                return false;
            }
        }

        return true;
    }

    function initialiseCaravanParameters( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();
        local typeModifier = (_settlement.isMilitary() || _settlement.isSouthern()) ? 1 : 0;
        local sizeModifier = _settlement.getSize() >= 3 ? 1 : 0;
        flags.set("CaravanWealth", ::Math.min(this.CaravanWealthDescriptors.Gilded, ::Math.rand(1, 2) + typeModifier + sizeModifier));

        if (::Math.rand(1, 500) <= this.CampaignModifiers.CaravanRareAndAboveChance && flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Gilded)
        {
            flags.set("CaravanCargo", this.CaravanCargoDescriptors.Oddities);
        }
        else
        {
            flags.set("CaravanCargo", ::Math.rand(this.CaravanCargoDescriptors.Rations, this.CaravanCargoDescriptors.Assortment));
        }
    }

    function retrieveCaravanCargo( _cargoValue, _caravanWealth )
    {
        local cargo = [];

        switch (_cargoValue)
        {
            case (this.CaravanCargoDescriptors.Oddities):
                cargo.extend(this.createNamedCaravanCargo(_caravanWealth));

            case (this.CaravanCargoDescriptors.Assortment):
                cargo.extend(this.createMundaneCaravanCargo("supplies/", _caravanWealth, true));

            case (this.CaravanCargoDescriptors.Trade):
                cargo.extend(this.createMundaneCaravanCargo("trade/", _caravanWealth, false));

            case (this.CaravanCargoDescriptors.Rations):
                cargo.extend(this.createMundaneCaravanCargo("supplies/", _caravanWealth, false));
                break;

            default:
                ::logError("Could not find matching caravan cargo descriptor.");
        }

        return cargo;
    }

    function setLairAgitation( _lair, _procedure )
    {
        local lairFlags = _lair.getFlags();

        switch (_procedure)
        {
            case (this.Procedures.Increment):
                lairFlags.increment("Agitation");
                break;

            case (this.Procedures.Decrement):
                lairFlags.increment("Agitation", -1);
                break;

            case (this.Procedures.Reset):
                lairFlags.set("Agitation", this.AgitationDescriptors.Relaxed);
                break;

            default:
                ::logError("[RPGR] setLairAgitation was called with an invalid procedure value.");
        }

        lairFlags.set("LastAgitationUpdate", ::World.getTime().Days);
        _lair.m.Resources = ::Math.floor(lairFlags.get("BaseResources") * lairFlags.get("Agitation") * ::RPGR_Raids.Mod.ModSettings.getSetting("AgitationResourceModifier"));
        _lair.setLootScaleBasedOnResources( _lair.m.Resources );
    }

    function setRaidedSettlementVisuals( _settlement, _isBurning )
    {
        local spriteBrushString = _isBurning == true ? "_ruins" : "";
        _settlement.getSprite("location_banner").Visible = !_isBurning;
		_settlement.getLabel("name").Visible = !_isBurning; // TODO: test if this works as envisioned
		_settlement.getSprite("body").setBrush(_settlement.m.Sprite + spriteBrushString);

        if (_isBurning)
        {
            _settlement.spawnFireAndSmoke()
        }
    }
};

::mods_registerMod(::RPGR_Raids.ID, ::RPGR_Raids.Version, ::RPGR_Raids.Name);
::mods_queue(::RPGR_Raids.ID, "mod_msu(>=1.2.6)", function()
{
    ::RPGR_Raids.Mod <- ::MSU.Class.Mod(::RPGR_Raids.ID, ::RPGR_Raids.Version, ::RPGR_Raids.Name);

    local pageGeneral = ::RPGR_Raids.Mod.ModSettings.addPage("General");

    local agitationDecayInterval = pageGeneral.addRangeSetting("AgitationDecayInterval", 7, 1, 14, 1.0, "Agitation Decay Interval"); // TODO: test this
    agitationDecayInterval.setDescription("Determines the time interval in days after which a location's agitation value drops by one tier.");

    local agitationIncrementChance = pageGeneral.addRangeSetting("AgitationIncrementChance", 100, 0, 100, 1.0, "Agitation Increment Chance");
    agitationIncrementChance.setDescription("Determines the chance for a location's agitation value to increase by one tier upon victory against a roaming party, if within proximity.");

    local agitationResourceModifier = pageGeneral.addRangeSetting("AgitationResourceModifier", 0.5, 0.0, 1.0, 0.1, "Agitation Resource Modifier");
    agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each agitation tier change. Higher values result in greater resources, and therefore more powerful garrisoned troops.");

    foreach( file in ::IO.enumerateFiles("mod_rpgr_raids/hooks") )
    {
        ::include(file);
    }
});