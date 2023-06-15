::RPGR_Brigandage <-
{
    ID = "mod_rpgr_brigandage",
    Name = "RPG Rebalance - Brigandage",
    Version = "1.0.0",
    AgitationDescriptors =
    {
        Relaxed = 1,
        Cautious = 2,
        Vigilant = 3,
        Desperate = 4
    },
    CaravanWealthDescriptors =
    { // determines likelihood and number of item occurrence + dynamically adds troops
        Impoverished = 1,
        Deprived = 2,
        Prosperous = 3,
        Gilded = 4
    },
    CaravanCargoDescriptors =
    {
        Provisions = 1,
        Trade = 2,
        Armaments = 3,
        Exotic = 4
    },
    CampaignModifiers =
    {
        CaravanRareAndAboveChance = 1,
        FamedChanceOnCampSpawn = 5,
        MaximumDistanceToAgitate = 20, // TODO: test this, find out if it's a reasonable value
        RareCargoBaseChance = 10
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

    function createMundaneCaravanCargo( _itemScriptPath, _caravanWealth )
    {
        local cargo = [];
        local scriptFiles = ::IO.enumerateFiles("scripts/items/" + _itemScriptPath);
        local iterations = ::Math.rand(1, _caravanWealth);

        for( local i = 0; i != iterations; i = ++i )
        {
            cargo.push(::new(scriptFiles[::Math.rand(0, scriptFiles.len() - 1)]));
        }

        return cargo;
    }

    function createRareCaravanCargo( _caravanWealth, _isSouthern )
    {
        local cargo = [];
        local armorCandidates =
        [
            "light_scale_armor",
            "reinforced_mail_hauberk",
            "sellsword_armor",
            "heavy_lamellar_armor",
            "footman_armor"
        ];
        local weaponCandidates =
        [
            "noble_sword",
            "fencing_sword",
            "fighting_axe",
            "greatsword",
            "war_bow"
        ];
        local southernCandidates =
        [

        ];

        if (::Math.rand(1, 100) > this.CampaignModifiers.RareCargoBaseChance * _caravanWealth)
        {
            return cargo;
        }

        if (_isSouthern)
        {
            cargo.push(::new("scripts/items" + southernCandidates[::Math.rand(0, southernCandidates.len() - 1)]));
            return cargo;
        }

        if (::Math.rand(1, 100) <= 50)
        {
            cargo.push(::new("scripts/items/armor/" + armorCandidates[::Math.rand(0, armorCandidates.len() - 1)]));
        }
        else
        {
            cargo.push(::new("scripts/items/weapons/" + weaponCandidates[::Math.rand(0, weaponCandidates.len() - 1)]));
        }

        return cargo;
    }

    function createNamedCaravanCargo( _caravanWealth )
    {

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
                score += smallestIncrement; // TODO: see if this needs correcting
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

    function initialiseCaravanParameters( _caravan, _settlement )
    { // TODO: figure out wealth-based troop reinforcement
        local wealthModifier = (_settlement.isMilitary() || _settlement.isSouthern()) ? _settlement.getSize() + 1 : _settlement.getSize();
        _caravan.getFlags().set("CaravanWealth", ::Math.min(this.CaravanWealthDescriptors.Gilded, ::Math.rand(0, 1) + wealthModifier));

        if (::Math.rand(1, 500) <= this.CampaignModifiers.CaravanRareAndAboveChance)
        {
            _caravan.getFlags().set("CaravanCargo", this.CaravanWealthDescriptors.Exotic);
        }
        else if (::Math.rand(1, 100) <= this.CampaignModifiers.CaravanRareAndAboveChance)
        {
            _caravan.getFlags().set("CaravanCargo", this.CaravanWealthDescriptors.Armaments);
        }
        else
        {
            _caravan.getFlags().set("CaravanCargo", ::Math.rand(this.CaravanWealthDescriptors.Provisions, this.CaravanWealthDescriptors.Trade));
        }
    }

    function retrieveCaravanCargo( _cargoValue, _caravanWealth, _isSouthern )
    {
        local cargo = [];

        switch (_cargoValue)
        {
            case (this.CaravanCargoDescriptors.Exotic):
                cargo.extend(this.createNamedCaravanCargo(_caravanWealth));

            case (this.CaravanCargoDescriptors.Armaments):
                cargo.extend(this.createRareCaravanCargo(_caravanWealth, _isSouthern));

            case (this.CaravanCargoDescriptors.Trade):
                cargo.extend(this.createMundaneCaravanCargo("trade",_caravanWealth));

            case (this.CaravanCargoDescriptors.Provisions):
                cargo.extend(this.createMundaneCaravanCargo("supplies",_caravanWealth));
                break;

            default:
                ::logError("Could not find matching caravan cargo descriptor.");
        }
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
                ::logError("RPGR - Brigandage: setLairAgitation was called with an invalid procedure value.");
        }

        lairFlags.set("LastAgitationUpdate", ::World.getTime().Days);
        _lair.m.Resources = ::Math.floor(lairFlags.get("BaseResources") * lairFlags.get("Agitation"));
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

::mods_registerMod(::RPGR_Brigandage.ID, ::RPGR_Brigandage.Version, ::RPGR_Brigandage.Name);
::mods_queue(::RPGR_Brigandage.ID, "mod_msu(>=1.2.6)", function()
{
    ::RPGR_Brigandage.Mod <- ::MSU.Class.Mod(::RPGR_Brigandage.ID, ::RPGR_Brigandage.Version, ::RPGR_Brigandage.Name);

    local pageGeneral = ::RPGR_Brigandage.Mod.ModSettings.addPage("General");

    local agitationDecayInterval = pageGeneral.addRangeSetting("AgitationDecayInterval", 7, 1, 14, 1.0, "Agitation Decay Interval"); // TODO: test this
    agitationDecayInterval.setDescription("Determines the time interval in days after which a location's agitation value drops by one tier.");

    local agitationIncrementChance = pageGeneral.addRangeSetting("AgitationIncrementChance", 100, 0, 100, 1.0, "Agitation Increment Chance");
    agitationIncrementChance.setDescription("Determines the chance for a location's agitation value to increase by one tier upon victory against a roaming party, if within proximity.");


    foreach( file in ::IO.enumerateFiles("mod_rpgr_brigandage/hooks") )
    {
        ::include(file);
    }
});