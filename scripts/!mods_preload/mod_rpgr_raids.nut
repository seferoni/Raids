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
        CaravanNamedLootChance = 1,
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

        foreach( excludedFile in exclusionList ) // TODO: test this
        {
            local index = scriptFiles.find(excludedFile);

            if (index != null)
            {
                ::logInfo("Removed " + excludedFile + " from supply pool.");
                scriptFiles.remove(index);
            }
        }

        for( local i = 0; i != iterations; i = ++i )
        {
            cargo.push(::new(scriptFiles[::Math.rand(0, scriptFiles.len() - 1)]));
        }

        return cargo;
    }

    function createNamedCaravanCargo()
    {
        local cargo = [];
        local namedLoot = this.createNamedLootArray();
        cargo.push(::new("scripts/items/" + namedLoot[::Math.rand(0, namedLoot.len() - 1)]));
        return cargo;
    }

    function createNamedLootArray()
    {
        local namedItemKeys = ["NamedArmors", "NamedHelmets", "NamedShields"]
        local namedLoot = clone ::Const.Items.NamedWeapons;

        foreach( key in namedItemKeys )
        {
            namedLoot.extend(::Const.Items[key]);
        }

        return namedLoot;
    }

    function depopulateLairNamedLoot( _lair )
    {
        // TODO: write this
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

    function getNamedLootChance( _lair )
    {
        local nearestSettlementDistance = 9000;
		local lairTile = _lair.getTile();

		foreach( settlement in ::World.EntityManager.getSettlements() )
		{
			local distance = lairTile.getDistanceTo(settlement.getTile());

			if (distance < nearestSettlementDistance)
			{
				nearestSettlementDistance = distance;
			}
		}

		return (_lair.m.Resources + nearestSettlementDistance * 4) / 5.0 - 37.0;
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

        local exclusionList = [::Const.FactionType.Beasts, ::Const.FactionType.Settlement, ::Const.FactionType.NobleHouse];
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
        flags.set("CaravanWealth", ::Math.min(this.CaravanWealthDescriptors.Opulent, ::Math.rand(1, 2) + typeModifier + sizeModifier));

        if (::Math.rand(1, 100) <= this.CampaignModifiers.CaravanNamedLootChance && flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Opulent)
        {
            flags.set("CaravanCargo", this.CaravanCargoDescriptors.Oddities);
        }
        else
        {
            flags.set("CaravanCargo", ::Math.rand(this.CaravanCargoDescriptors.Rations, this.CaravanCargoDescriptors.Assortment));
        }
    }

    function repopulateLairNamedLoot( _lair )
    { // with an agitation value of 4 and a configured setting of 25, end up with a guaranteed chance for named item spawn which is not desirable? should be some buffer
        local namedLootChance = this.getNamedLootChance(_lair);
        ::logInfo("namedLootChance is " + namedLootChance + " for lair " + _lair.getName());
        #local namedLootChance = this.Mod.ModSettings.getSetting("LairNamedLootChance").getValue() * _lair.getFlags().get("Agitation"); // TODO: reconsider this

        if (::Math.rand(1, 100) > namedLootChance)
        {
            return;
        }

        local namedLoot = this.createNamedLootArray();
        _lair.m.Loot.add(::new("scripts/items/" + namedLoot[::Math.rand(0, namedLoot.len() - 1)]));
    }

    function retrieveCaravanCargo( _cargoValue, _caravanWealth )
    {
        local cargo = [];

        switch (_cargoValue)
        {
            case (this.CaravanCargoDescriptors.Oddities):
                cargo.extend(this.createNamedCaravanCargo());

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
                this.repopulateLairNamedLoot(_lair);
                break;

            case (this.Procedures.Decrement):
                lairFlags.increment("Agitation", -1);
                this.depopulateLairNamedLoot(_lair);
                break;

            case (this.Procedures.Reset):
                lairFlags.set("Agitation", this.AgitationDescriptors.Relaxed);
                this.depopulateLairNamedLoot(_lair);
                break;

            default:
                ::logError("[Raids] setLairAgitation was called with an invalid procedure value.");
        }

        lairFlags.set("LastAgitationUpdate", ::World.getTime().Days);
        _lair.m.Resources = ::Math.floor(lairFlags.get("BaseResources") * lairFlags.get("Agitation") * this.Mod.ModSettings.getSetting("AgitationResourceModifier"));
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

    local agitationIncrementChance = pageGeneral.addRangeSetting("AgitationIncrementChance", 100, 0, 100, 1.0, "Agitation Increment Chance"); // TODO: this should be default 50 when raids ship
    agitationIncrementChance.setDescription("Determines the chance for a location's agitation value to increase by one tier upon victory against a roaming party, if within proximity.");

    local agitationResourceModifier = pageGeneral.addRangeSetting("AgitationResourceModifier", 0.5, 0.0, 1.0, 0.1, "Agitation Resource Modifier"); // TODO: test if MSU doesn't fuck up float display
    agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each agitation tier change. Higher values result in greater resources, and therefore more powerful garrisoned troops and better loot.");

    local lairNamedLootChance = pageGeneral.addRangeSetting("LairNamedLootChance", 12, 1, 25, 1.0, "Lair Named Item Chance");
    lairNamedLootChance.setDescription("Determines the base chance for lairs to contain new named items when agitation is incremented.");

    foreach( file in ::IO.enumerateFiles("mod_rpgr_raids/hooks") )
    {
        ::include(file);
    }
});