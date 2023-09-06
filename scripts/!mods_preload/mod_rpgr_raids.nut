::RPGR_Raids <-
{
    ID = "mod_rpgr_raids",
    Name = "RPG Rebalance - Raids",
    Version = "1.0.0",
    AgitationDescriptors =  // TODO: rename these to reflect greater strength
    {
        Relaxed = 1,
        Cautious = 2,
        Vigilant = 3,
        Desperate = 4
    },
    CaravanWealthDescriptors =
    {
        Light = 1,
        Moderate = 2,
        Plentiful = 3,
        Abundant = 4
    },
    CaravanCargoDescriptors =
    {
        Supplies = 1,
        Trade = 2,
        Assortment = 3,
        Unassorted = 4
    },
    CampaignModifiers =
    {
        AssignmentMaximumTroopOffset = 7,
        AssignmentResourceThreshold = 6,
        AssignmentResourceThresholdPercentage = 50.0,
        CaravanNamedItemChance = 50, // FIXME: this is inflated, revert to 5
        GlobalProximityTiles = 9,
        LairNamedItemChance = 30,
        ReinforcementMaximumTroopOffset = 7, // TODO: balance this
        ReinforcementThresholdDays = 1 // FIXME: this is deflated, revert to 50
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    },

    function addToCaravanInventory( _caravan, _goodsPool )
    {
        local iterations = ::Math.rand(1, _caravan.getFlags().get("CaravanWealth") - 1);

        for( local i = 0; i < iterations; i++ )
        {
            local good = _goodsPool[::Math.rand(0, _goodsPool.len() - 1)];
            this.logWrapper(format("Added item with filepath %s to caravan inventory.", good));
            _caravan.addToInventory(good);
        }
    }

    function agitateViableLairs( _lairs, _iterations = 1 )
    {
        local viableLairs = _lairs.filter(function( lairIndex, lair )
        {
            return !::RPGR_Raids.isActiveContractLocation(lair);
        });

        for( local i = 0; i < _iterations; i++ )
        {
            foreach( lair in viableLairs )
            {
                this.logWrapper("Found lair candidate.");
                this.setLairAgitation(lair, this.Procedures.Increment);
            }
        }
    }

    function areCaravanFlagsInitialised( _flags )
    {
        return _flags.get("CaravanWealth") != false && _flags.get("CaravanCargo") != false;
    }

    function assignTroops( _party, _partyList, _resources )
    {
        local troopsTemplate = this.selectRandomPartyTemplate(_party, _partyList, _resources);

        if (troopsTemplate.len() == 0)
        {
            return false;
        }

        for( local i = 0; i < iterations; i++ )
        {
            ::Const.World.Common.addTroop(_party, troopsTemplate[index], false);
        }

        /*local bailOut = 0;

        while (_resources >= 0 && bailOut < this.CampaignModifiers.AssignmentMaximumTroopOffset)
        {
            foreach( troop in troopsTemplate )
            {
                ::Const.World.Common.addTroop(_party, troop, false);
                _resources -= troop.Type.Cost;
            }

            bailOut += troopsTemplate.len();
        }*/

        _party.updateStrength();
        return true;
    }

    function calculateSettlementSituationModifier( _settlement )
    {
        local modifier = 0;
        local smallestIncrement = 1.0;
        local synergisticSituations =
        [
            "situation.well_supplied",
            "situation.good_harvest",
            "situation.safe_roads"
        ];
        local antagonisticSituations =
        [
            "situation.ambushed_trade_routes",
            "situation.disappearing_villagers",
            "situation.greenskins",
            "situation.raided"
        ];

        foreach( situation in synergisticSituations ) // TODO: this is not efficient
        {
            if (_settlement.getSituationByID(situation) != null)
            {
                modifier += smallestIncrement;
            }
        }

        foreach( situation in antagonisticSituations )
        {
            if (_settlement.getSituationByID(situation) != null)
            {
                modifier -= smallestIncrement;
            }
        }

        return modifier;
    }

    function createCaravanCargo( _caravan, _settlement )
    {
        local produce = _settlement.getProduce();
        local flags = _caravan.getFlags();
        local descriptor = this.getDescriptor(flags.get("CaravanCargo"), this.CaravanCargoDescriptors).tolower();
        local actualProduce = produce.filter(function( index, value )
        {
            return value.find(descriptor) != null;
        });

        if (actualProduce.len() == 0)
        {
            this.logWrapper(format("%s has no produce corresponding to caravan cargo type.", _settlement.getName()));
            local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CaravanCargoDescriptors.Assortment : this.CaravanCargoDescriptors.Unassorted;
            flags.set("CaravanCargo", newCargoType);

            if (newCargoType == this.CaravanCargoDescriptors.Assortment)
            {
                this.createNaiveCaravanCargo(_caravan);
                return;
            }

            this.addToCaravanInventory(_caravan, produce);
            return;
        }

        this.addToCaravanInventory(_caravan, actualProduce);
    }

    function createNaiveCaravanCargo( _caravan )
    {
        local exclusionList =
        [
            "supplies/food_item",
            "supplies/money_item",
            "trade/trading_good_item",
            "supplies/strange_meat_item",
            "supplies/fermented_unhold_heart_item",
            "supplies/black_marsh_stew_item"
        ];
        local southernGoods =
        [
            "supplies/dates_item",
            "supplies/rice_item",
            "trade/silk_item",
            "trade/spices_item",
            "trade/incense_item"
        ];

        if (::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.OrientalCityState)
        {
            this.addToCaravanInventory(_caravan, southernGoods);
            return;
        }

        exclusionList.extend(southernGoods);
        local scriptFiles = ::IO.enumerateFiles("scripts/items/supplies");
        scriptFiles.extend(::IO.enumerateFiles("scripts/items/trade"));

        foreach( excludedFile in exclusionList )
        {
            local index = scriptFiles.find("scripts/items/" + excludedFile);

            if (index != null)
            {
                scriptFiles.remove(index);
            }
        }

        local culledString = "scripts/items/";
        local goods = scriptFiles.map(function( stringPath )
        {
            return stringPath.slice(culledString.len());
        });
        this.addToCaravanInventory(_caravan, goods);
    }

    function createCaravanTroops( _wealth, _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.Billman,
                ::Const.World.Spawn.Troops.Footman,
                ::Const.World.Spawn.Troops.Arbalester,
                ::Const.World.Spawn.Troops.ArmoredWardog
            ]);

            return troops;
        }

        if (_wealth >= this.CaravanWealthDescriptors.Plentiful)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.MercenaryLOW,
            ]);

            if (::World.getTime().Days >= this.CampaignModifiers.ReinforcementThresholdDays)
            {
                troops.extend([
                    ::Const.World.Spawn.Troops.Mercenary,
                    ::Const.World.Spawn.Troops.MercenaryRanged,
                ]);
            }
        }

        if (_factionType == ::Const.FactionType.OrientalCityState)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.Conscript,
                ::Const.World.Spawn.Troops.ConscriptPolearm
            ]);
        }
        else
        {
            troops.extend([
                ::Const.World.Spawn.Troops.CaravanHand,
                ::Const.World.Spawn.Troops.CaravanGuard
            ]);
        }

        return troops;
    }

    function createEliteCaravanTroops( _factionType )
    {
        local troops = [];

        if (_factionType == ::Const.FactionType.NobleHouse)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.MasterArcher,
                ::Const.World.Spawn.Troops.Greatsword,
                ::Const.World.Spawn.Troops.Knight
            ]);

            return troops;
        }

        troops.extend([
            ::Const.World.Spawn.Troops.HedgeKnight,
            ::Const.World.Spawn.Troops.Swordmaster
        ]);

        return troops;
    }

    function createNaiveNamedLoot( _namedItemKeys )
    {
        local namedLoot = [];

        foreach( key in _namedItemKeys )
        {
            namedLoot.extend(::Const.Items[key]);
        }

        return namedLoot;
    }

    function createNamedLoot( _lair = null )
    {
        local namedItemKeys = ["NamedArmors", "NamedWeapons", "NamedHelmets", "NamedShields"];

        if (_lair == null)
        {
            return this.createNaiveNamedLoot(namedItemKeys);
        }

        local namedLoot = [];

        foreach( key in namedItemKeys )
        {
            if (_lair.m[key + "List"] != null)
            {
                namedLoot.extend(_lair.m[key + "List"]);
            }
        }

        if (namedLoot.len() == 0)
        {
            return this.createNaiveNamedLoot(namedItemKeys);
        }

        return namedLoot;
    }

    function depopulateLairNamedLoot( _lair, _chance = null )
    {
        if (_lair.getLoot().isEmpty())
        {
            return;
        }

        local namedLootChance = _chance == null ? this.getNamedLootChance(_lair) : _chance;

        if (::Math.rand(1, 100) <= namedLootChance)
        {
            return;
        }

        local garbage = [];
        local items = _lair.getLoot().getItems();

        foreach( item in items )
        {
            if (item.isItemType(::Const.Items.ItemType.Named))
            {
                garbage.push(item);
            }
        }

        foreach( item in garbage )
        {
            local index = items.find(item);
            items.remove(index);
            this.logWrapper(format("Removed %s at index %i.", item.getName(), index));
        }
    }

    function findLairCandidates( _faction )
    {
        if (!this.isFactionViable(_faction))
        {
            this.logWrapper("findLairCandidates took on a non-viable faction as an argument.");
            return null;
        }

        if (_faction.getSettlements().len() == 0)
        {
            this.logWrapper("findLairCandidates was passed a viable faction as an argument, but this faction has no settlements at present.");
            return null;
        }

        this.logWrapper("Proceeding to lair candidate selection.");
        local lairs = _faction.getSettlements().filter(function( locationIndex, location )
        {
            return ::RPGR_Raids.isLocationTypeViable(location.getLocationType()) && ::RPGR_Raids.isPlayerInProximityTo(location.getTile());
        });

        if (lairs.len() == 0)
        {
            this.logWrapper("findLairCandidates could not find any lairs within proximity of the player.");
            return null;
        }

        return lairs;
    }

    function generateTooltipTableEntry( _id, _type, _icon, _text )
    {
        local tableEntry =
        {
            id = _id,
            type = _type,
            icon = _icon,
            text = _text
        }

        return tableEntry;
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

		foreach( settlement in ::World.EntityManager.getSettlements() ) // TODO: find a more efficient way of doing this
		{
			local distance = lairTile.getDistanceTo(settlement.getTile());

			if (distance < nearestSettlementDistance)
			{
				nearestSettlementDistance = distance;
			}
		}

		return (_lair.getResources() + nearestSettlementDistance * 4) / 5.0 - 37.0;
    }

    function logWrapper( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError(format("[Raids] %s", _string));
            return;
        }

        if (!this.Mod.ModSettings.getSetting("VerboseLogging").getValue())
        {
            return;
        }

        ::logInfo(format("[Raids] %s", _string));
    }

    function initialiseCaravanParameters( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();
        local typeModifier = (_settlement.isMilitary() || _settlement.isSouthern()) ? 1 : 0;
        local sizeModifier = _settlement.getSize() >= 3 ? 1 : 0;
        local situationModifier = this.calculateSettlementSituationModifier(_settlement) > 0 ? 1 : 0;
        local distributions =
        {
            Supplies = 50,
            Trade = 100,
            Assortment = 20
        };
        flags.set("CaravanWealth", ::Math.min(this.CaravanWealthDescriptors.Abundant, ::Math.rand(1, 2) + typeModifier + sizeModifier + situationModifier));

        if (::Math.rand(1, 100) <= this.CampaignModifiers.CaravanNamedItemChance && flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Abundant && ::World.getTime().Days >= this.CampaignModifiers.ReinforcementThresholdDays)
        {
            flags.set("CaravanHasNamedItems", true);
        }

        local randomNumber = ::Math.rand(1, 100);
        local cargoType = (randomNumber <= distributions.Assortment || _settlement.getProduce().len() == 0) ? "Assortment" : randomNumber <= distributions.Supplies ? "Supplies" : "Trade";
        flags.set("CaravanCargo", this.CaravanCargoDescriptors[cargoType]);
        this.logWrapper(format("Rolled %i for caravan cargo assignment for caravan from %s of the newly assigned cargo type %s.", randomNumber, _settlement.getName(), this.getDescriptor(flags.get("CaravanCargo"), this.CaravanCargoDescriptors)));
        this.populateCaravanInventory(_caravan, _settlement);

        if (::Math.rand(1, 100) <= this.Mod.ModSettings.getSetting("CaravanReinforcementChance").getValue() || flags.get("CaravanWealth") >= this.CaravanWealthDescriptors.Plentiful)
        {
            this.reinforceCaravanTroops(_caravan, _settlement);
        }
    }

    function isActiveContractLocation( _lair )
    {
        local activeContract = ::World.Contracts.getActiveContract();

        if (activeContract == null)
        {
            return false;
        }

        if (!("Destination" in activeContract.m))
        {
            return false;
        }

        if (activeContract.m.Destination.get() == _lair)
        {
            this.logWrapper(format("%s was found to be an active contract location, aborting.", lair.getName()));
            return true;
        }

        return false;
    }

    function isFactionViable( _faction )
    {
        if (_faction == null)
        {
            return false;
        }

        local exclusionList =
        [
            ::Const.FactionType.Beasts,
            ::Const.FactionType.Player,
            ::Const.FactionType.Settlement,
            ::Const.FactionType.NobleHouse,
            ::Const.FactionType.OrientalCityState
        ];
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

    function isLocationTypeViable( _locationType )
    {
        return _locationType == ::Const.World.LocationType.Lair || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Mobile);
    }

    function isLairEligibleForProcedure( _lair, _procedure )
    {
        local agitationState = _lair.getFlags().get("Agitation");
        local lairName = _lair.getName();

        if (agitationState > this.AgitationDescriptors.Desperate || agitationState < this.AgitationDescriptors.Relaxed)
        {
            this.logWrapper(format("Agitation for %s occupies an out-of-bounds value.", lairName), true);
            return false;
        }

        if (_procedure == this.Procedures.Increment && agitationState >= this.AgitationDescriptors.Desperate)
        {
            this.logWrapper(format("Agitation for %s is capped, aborting procedure.", lairName));
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitationState <= this.AgitationDescriptors.Relaxed)
        {
            this.logWrapper(format("Agitation for %s is already at its minimum value, aborting procedure.", lairName));
            return false;
        }

        this.logWrapper(format("Lair %s is eligible for agitation state change procedures.", lairName));
        return true;
    }

    function isPartyViable( _flags )
    {
        return _flags.get("IsCaravan");
    }

    function isPlayerInProximityTo( _targetTile )
    {
        return ::World.State.getPlayer().getTile().getDistanceTo(_targetTile) <= this.CampaignModifiers.GlobalProximityTiles;
    }

    function isTroopViable( _troop )
    {
        local exclusionList =
        [
            ::Const.World.Spawn.Troops.BarbarianBeastmaster,
            ::Const.World.Spawn.Troops.BarbarianUnhold,
            ::Const.World.Spawn.Troops.Warhound
        ]

        foreach( excludedTroop in exclusionList )
        {
            if (_troop.Type == excludedTroop)
            {
                return false;
            }
        }

        return true;
    }

    function populateCaravanInventory( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();

        if (flags.get("CaravanWealth") == this.CaravanWealthDescriptors.Light)
        {
            return;
        }

        if (flags.get("CaravanCargo") == this.CaravanCargoDescriptors.Assortment)
        {
            this.createNaiveCaravanCargo(_caravan);
            return;
        }

        this.createCaravanCargo(_caravan, _settlement);
    }

    function reinforceCaravanTroops( _caravan, _settlement )
    {
        local flags = _caravan.getFlags();
        local wealth = flags.get("CaravanWealth");

        if (wealth == this.CaravanWealthDescriptors.Light)
        {
            return;
        }

        local currentTimeDays = ::World.getTime().Days;
        local timeModifier = ::Math.floor(currentTimeDays / this.CampaignModifiers.ReinforcementThresholdDays);
        local naiveIterations = ::Math.rand(1, wealth * 2) + timeModifier;
        local iterations = naiveIterations > this.CampaignModifiers.ReinforcementMaximumTroopOffset ? this.CampaignModifiers.ReinforcementMaximumTroopOffset : naiveIterations;
        local factionType = ::World.FactionManager.getFaction(_caravan.getFaction()).getType();
        local mundaneTroops = this.createCaravanTroops(wealth, factionType);

        for( local i = 0; i <= iterations; i = ++i )
        {
            ::Const.World.Common.addTroop(_caravan, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, true);
        }

        if (!(wealth == this.CaravanWealthDescriptors.Abundant && flags.get("CaravanHasNamedItems")))
        {
            return;
        }

        if (currentTimeDays < this.CampaignModifiers.ReinforcementThresholdDays)
        {
            return;
        }

        local eliteTroops = this.createEliteCaravanTroops(factionType);
        ::Const.World.Common.addTroop(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, true);
    }

    function repopulateLairNamedLoot( _lair )
    {
        local namedLootChance = this.getNamedLootChance(_lair);
        this.logWrapper(format("namedLootChance is %g for lair %s.", namedLootChance, _lair.getName()));

        if (::Math.rand(1, 100) > namedLootChance)
        {
            return;
        }

        local namedLoot = this.createNamedLoot(_lair);
        _lair.getLoot().add(::new("scripts/items/" + namedLoot[::Math.rand(0, namedLoot.len() - 1)]));
    }

    function retrieveCaravanCargoIconPath( _cargoValue )
    {
        local iconPath = null;

        switch (_cargoValue)
        {
            case (this.CaravanCargoDescriptors.Unassorted):
                iconPath = "bag.png";
                break;

            case (this.CaravanCargoDescriptors.Assortment):
                iconPath = "asset_money.png";
                break;

            case(this.CaravanCargoDescriptors.Trade):
                iconPath = "money.png";
                break;

            case(this.CaravanCargoDescriptors.Supplies):
                iconPath = "asset_food.png"
                break;

            default:
                this.logWrapper("Invalid caravan cargo value, unable to retrieve icon.", true);
        }

        return iconPath;
    }

    function retrieveNamedCaravanCargo( _lootTable )
    {
        local namedCargo = this.createNamedLoot();
        local namedItem = ::new("scripts/items/" + namedCargo[::Math.rand(0, namedCargo.len() - 1)]);
        namedItem.onAddedToStash(null);
        this.logWrapper(format("Added %s to the loot table.", namedItem.getName()));
        _lootTable.push(namedItem);
    }

    function selectRandomPartyTemplate( _party, _partyList, _resources )
    {
        local troopsTemplate = [];
        local bailOut = 0;
        local maximumIterations = 10;
        local currentResources = _resources;

        while (currentResources > 0.0 && bailOut < maximumIterations) // FIXME: this is dumb.
        {
            local partyTemplateCandidate = _partyList[::Math.rand(0, _partyList.len() - 1)];
            troopsTemplate.extend(partyTemplateCandidate.Troops.filter(function( troopIndex, troop )
            {
                if (!::RPGR_Raids.isTroopViable(troop))
                {
                    return false;
                }

                if (troop.Type.Cost > currentResources)
                {
                    return false;
                }

                currentResources -= troop.Type.Cost;
                return true;
            }));
            bailOut += 1;
        }

        if (bailOut == maximumIterations)
        {
            this.logWrapper(format("Exceeded maximum iterations for troop assignment for party %s.", _party.getName()));
        }

        if (troopsTemplate.len() <= 1)
        {
            return troopsTemplate;
        }

        troopsTemplate.sort(function( _firstTroop, _secondTroop )
        {
            if (_firstTroop.Type.Cost > _secondTroop.Type.Cost)
            {
                return -1;
            }

            return 1;
        });

        return troopsTemplate;
    }

    function setLairAgitation( _lair, _procedure )
    {
        if (!this.isLairEligibleForProcedure(_lair, _procedure))
        {
            return;
        }

        local flags = _lair.getFlags();

        switch (_procedure)
        {
            case (this.Procedures.Increment):
                flags.increment("Agitation");
                this.repopulateLairNamedLoot(_lair);
                break;

            case (this.Procedures.Decrement):
                flags.increment("Agitation", -1);
                this.depopulateLairNamedLoot(_lair);
                break;

            case (this.Procedures.Reset):
                flags.set("Agitation", this.AgitationDescriptors.Relaxed);
                this.depopulateLairNamedLoot(_lair);
                break;

            default:
                this.logWrapper("setLairAgitation was called with an invalid procedure value.", true);
        }

        flags.set("LastAgitationUpdate", ::World.getTime().Days);
        _lair.m.Resources = flags.get("Agitation") == this.AgitationDescriptors.Relaxed ? flags.get("BaseResources") : ::Math.floor(flags.get("BaseResources") * flags.get("Agitation") * (this.Mod.ModSettings.getSetting("AgitationResourceModifier").getValue() / 100.0));
        ::RPGR_Raids.logWrapper("Refreshing lair defender roster on agitation update.");
        _lair.createDefenders();
        _lair.setLootScaleBasedOnResources(_lair.getResources());
    }

    function updateCumulativeLairAgitation( _lair )
    {
        local flags = _lair.getFlags();
        local lastUpdateTimeDays = flags.get("LastAgitationUpdate");

        if (lastUpdateTimeDays == false)
        {
            return;
        }

        local currentTimeDays = ::World.getTime().Days;
        local decayInterval = this.Mod.ModSettings.getSetting("AgitationDecayInterval").getValue();
        local timeDifference = currentTimeDays - lastUpdateTimeDays;

        if (timeDifference < decayInterval)
        {
            return;
        }

        this.logWrapper(format("Last agitation update occurred %i days ago.", timeDifference));
        local decrementIterations = ::Math.floor(timeDifference / decayInterval);

        for( local i = 0; i != decrementIterations; i = ++i )
        {
            this.setLairAgitation(_lair, this.Procedures.Decrement);

            if (flags.get("Agitation") == this.AgitationDescriptors.Relaxed)
            {
                break;
            }
        }
    }
};

::mods_registerMod(::RPGR_Raids.ID, ::RPGR_Raids.Version, ::RPGR_Raids.Name);
::mods_queue(::RPGR_Raids.ID, "mod_msu(>=1.2.6)", function()
{
    ::RPGR_Raids.Mod <- ::MSU.Class.Mod(::RPGR_Raids.ID, ::RPGR_Raids.Version, ::RPGR_Raids.Name);

    local pageGeneral = ::RPGR_Raids.Mod.ModSettings.addPage("General");
    local pageLairs = ::RPGR_Raids.Mod.ModSettings.addPage("Lairs");
    local pageCaravans = ::RPGR_Raids.Mod.ModSettings.addPage("Caravans");

    local agitationDecayInterval = pageLairs.addRangeSetting("AgitationDecayInterval", 7, 1, 50, 1, "Agitation Decay Interval");
    agitationDecayInterval.setDescription("Determines the time interval in days after which a location's agitation value drops by one tier.");

    local agitationIncrementChance = pageLairs.addRangeSetting("AgitationIncrementChance", 100, 0, 100, 1, "Agitation Increment Chance"); // TODO: this should be default 50 when raids ship
    agitationIncrementChance.setDescription("Determines the chance for a location's agitation value to increase by one tier upon engagement with a roaming party, if within proximity.");

    local agitationResourceModifier = pageLairs.addRangeSetting("AgitationResourceModifier", 70, 50, 100, 10, "Agitation Resource Modifier"); //
    agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each agitation tier change. Higher percentage values result in greater resources, and therefore more powerful garrisoned troops and better loot.");

    local roamerScaleChance = pageLairs.addRangeSetting("RoamerScaleChance", 100, 1, 100, 1, "Roamer Scale Chance");
    roamerScaleChance.setDescription("Determines the percentage chance for hostile roaming and ambusher parties spawning from lairs to scale in strength with respect to the originating lair's resource count. Does not affect beasts.");

    local roamerResourceModifier = pageLairs.addRangeSetting("RoamerResourceModifier", 70, 70, 100, 10, "Roamer Resource Modifier"); //
    roamerResourceModifier.setDescription("Controls how resource calculation is handled for roaming parties. Higher percentage values result in greater resources, and therefore more powerful roaming troops. Does nothing if roamer scale chance is set to zero.");

    local depopulateLairLootOnSpawn = pageLairs.addBooleanSetting("DepopulateLairLootOnSpawn", false, "Depopulate Lair Loot On Spawn");
    depopulateLairLootOnSpawn.setDescription("Determines whether Raids should depopulate newly spawned lairs of named loot. This is recommended to compensate for the additional named loot brought about by the introduction of agitation as a game mechanic.");

    local roamerScaleAgitationRequirement = pageLairs.addBooleanSetting("RoamerScaleAgitationRequirement", false, "Roamer Scale Agitation Requirement");
    roamerScaleAgitationRequirement.setDescription("Determines whether roamer scaling occurs for lairs with baseline agitation. Will result in stronger eligible roamer spawns on a game-wide basis.");

    local caravanReinforcementChance = pageCaravans.addRangeSetting("CaravanReinforcementChance", 100, 1, 100, 1, "Caravan Reinforcement Chance");
    caravanReinforcementChance.setDescription("Determines the percentage change for caravan troop count and composition reinforcement based on caravan wealth, and in special cases, cargo type. If certain conditions obtain, this will also result in the addition of special troops with powerful end-game gear to wealthy caravans, independent of player progression.");

    local handleSupplyCaravans = pageCaravans.addBooleanSetting("HandleSupplyCaravans", false, "Handle Supply Caravans");
    handleSupplyCaravans.setDescription("Determines whether Raids should handle supply caravans in the same manner as trading caravans, or if they should behave as in the base game.");

    local verboseLogging = pageGeneral.addBooleanSetting("VerboseLogging", true, "Verbose Logging"); // TODO: set this to false when done
    verboseLogging.setDescription("Enables verbose logging. Recommended for testing purposes only, as the volume of logged messages can make parsing the log more difficult for general use and debugging.");

    foreach( file in ::IO.enumerateFiles("mod_rpgr_raids/hooks") )
    {
        ::include(file);
    }
});