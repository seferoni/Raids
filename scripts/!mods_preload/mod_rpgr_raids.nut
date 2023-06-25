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
        CaravanNamedLootChance = 50, // FIXME: this is inflated, revert to 5
        FamedChanceOnCampSpawn = 30,
        MaximumDistanceToAgitate = 9
    },
    Procedures =
    {
        Increment = 1,
        Decrement = 2,
        Reset = 3
    }

    function createMundaneCaravanCargo( _caravanWealth, _isAssorted, _folderPath = null, _isSouthern = false )
    {
        local cargo = [];
        local assortedGoods = ["ammo_item", "medicine_item", "armor_parts_item"];
        local iterations = ::Math.rand(1, _caravanWealth);

        if (_isAssorted)
        {
            for( local i = 0; i != iterations; i = ++i )
            {
                cargo.push(::new("scripts/items/supplies/" + assortedGoods[::Math.rand(0, assortedGoods.len() - 1)]));
            }

            return cargo;
        }

        local exclusionList = ["food_item", "money_item", "trading_good_item", "strange_meat_item", "fermented_unhold_heart_item", "black_marsh_stew_item"];
        exclusionList.extend(assortedGoods);
        local southernCandidates = ["dates_item", "rice_item", "silk_item", "spices_item"];
        local scriptFiles = ::IO.enumerateFiles("scripts/items/" + _folderPath);

        if (_isSouthern)
        {
            local southernGoods = southernCandidates.filter(function( index, candidate )
            {
                return scriptFiles.find("scripts/items/" + _folderPath + candidate) != null;
            });

            for( local i = 0; i != iterations; i = ++i )
            {
                cargo.push(::new("scripts/items/" + _folderPath + southernGoods[::Math.rand(0, southernGoods.len() - 1)]));
            }

            return cargo;
        }

        exclusionList.extend(southernCandidates);

        foreach( excludedFile in exclusionList )
        {
            local index = scriptFiles.find("scripts/items/" + _folderPath + excludedFile);

            if (index != null)
            {
                scriptFiles.remove(index);
            }
        }

        for( local i = 0; i != iterations; i = ++i )
        {
            cargo.push(::new(scriptFiles[::Math.rand(0, scriptFiles.len() - 1)]));
        }

        return cargo;
    }

    function createCaravanTroops( _caravan, _isMilitary )
    {
        local troops = [];

        if (_isMilitary)
        {
            troops.extend([
                ::Const.World.Spawn.Troops.Billman,
                ::Const.World.Spawn.Troops.Footman,
                ::Const.World.Spawn.Troops.Arbalester,
                ::Const.World.Spawn.Troops.ArmoredWardog
            ]);

            return troops;
        }

        troops.extend([
            ::Const.World.Spawn.Troops.MercenaryLOW,
            ::Const.World.Spawn.Troops.Mercenary,
            ::Const.World.Spawn.Troops.MercenaryRanged
        ]);

        return troops;
    }

    function createEliteCaravanTroops( _caravan, _isMilitary )
    {
        local troops = [];

        if (_isMilitary)
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

    function createNamedCaravanCargo()
    {
        local cargo = [];
        local namedLoot = this.createNamedLoot();
        local namedItem = ::new("scripts/items/" + namedLoot[::Math.rand(0, namedLoot.len() - 1)]);

        if (namedItem.m.Name.len() == 0)
		{
			namedItem.setName(namedItem.createRandomName());
		}

        cargo.push(namedItem);
        return cargo;
    }

    function createNamedLoot( _lair = null )
    { // FIXME: there is no point in extending this with what the lair alr has
        local namedItemKeys = ["NamedArmors", "NamedWeapons", "NamedHelmets", "NamedShields"]
        local namedLoot = [];

        foreach( key in namedItemKeys )
        {
            namedLoot.extend(::Const.Items[key]);

            if (_lair != null && _lair.m[key + "List"] != null)
            {
                namedLoot.extend(_lair.m[key + "List"]);
            }
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
            ::logInfo("Removed " + item.m.Name + " at index " + index + ".");
        }
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

    function isLairEligible(_flags, _procedure)
    {
        local agitationState = _flags.get("Agitation");
        if (_procedure == this.Procedures.Increment && agitationState >= this.AgitationDescriptors.Desperate)
        {
            ::logInfo("Agitation is capped, bailing.");
            return false;
        }

        if (_procedure == this.Procedures.Decrement && agitationState <= this.AgitationDescriptors.Relaxed)
        {
            return false;
        }

        ::logInfo("Lair is eligible.");
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

        this.reinforceCaravanTroops(_caravan);
    }

    function reinforceCaravanTroops( _caravan )
    { // TODO: rebalance this
        local flags = _caravan.getFlags();
        local wealth = flags.get("CaravanWealth");

        if (wealth < this.CaravanWealthDescriptors.Deprived)
        {
            return;
        }

        local cargo = flags.get("CaravanCargo");
        local iterations = ::Math.rand(1, wealth + cargo);
        local isMilitary = ::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.NobleHouse;
        local mundaneTroops = this.createCaravanTroops(_caravan, isMilitary);

        for( local i = 0; i != iterations; i = ++i )
        {
            ::Const.World.Common.addTroop(_caravan, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, true);
        }

        if (!(wealth == this.CaravanWealthDescriptors.Opulent && cargo == this.CaravanCargoDescriptors.Oddities))
        {
            return;
        }

        local eliteTroops = this.createEliteCaravanTroops(_caravan, isMilitary);
        ::Const.World.Common.addTroop(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, true);
    }

    function repopulateLairNamedLoot( _lair )
    {
        local namedLootChance = this.getNamedLootChance(_lair);
        ::logInfo("namedLootChance is " + namedLootChance + " for lair " + _lair.getName());

        if (::Math.rand(1, 100) > namedLootChance)
        {
            return;
        }

        local namedLoot = this.createNamedLoot(_lair);
        _lair.m.Loot.add(::new("scripts/items/" + namedLoot[::Math.rand(0, namedLoot.len() - 1)]));
    }

    function retrieveCaravanCargo( _cargoValue, _caravanWealth, _isSouthern )
    {
        local cargo = [];

        switch (_cargoValue)
        {
            case (this.CaravanCargoDescriptors.Oddities):
                cargo.extend(this.createNamedCaravanCargo());

            case (this.CaravanCargoDescriptors.Assortment):
                cargo.extend(this.createMundaneCaravanCargo(_caravanWealth, true));

            case (this.CaravanCargoDescriptors.Trade):
                cargo.extend(this.createMundaneCaravanCargo(_caravanWealth, false, "trade/", _isSouthern));

            case (this.CaravanCargoDescriptors.Rations):
                cargo.extend(this.createMundaneCaravanCargo(_caravanWealth, false, "supplies/", _isSouthern));
                break;

            default:
                ::logError("[Raids] Could not find matching caravan cargo descriptor.");
        }

        return cargo;
    }

    function setLairAgitation( _lair, _procedure )
    {
        local flags = _lair.getFlags();
        local isLairEligible = this.isLairEligible(flags, _procedure);

        if (!isLairEligible)
        {
            return;
        }

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
                ::logError("[Raids] setLairAgitation was called with an invalid procedure value.");
        }

        flags.set("LastAgitationUpdate", ::World.getTime().Days);
        _lair.m.Resources = flags.get("Agitation") == this.AgitationDescriptors.Relaxed ? flags.get("BaseResources") : ::Math.floor(flags.get("BaseResources") * flags.get("Agitation") * this.Mod.ModSettings.getSetting("AgitationResourceModifier").getValue());
        _lair.setLootScaleBasedOnResources(_lair.m.Resources);
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

    local agitationResourceModifier = pageGeneral.addRangeSetting("AgitationResourceModifier", 0.7, 0.0, 1.0, 0.1, "Agitation Resource Modifier"); // FIXME: Floating number display bug
    agitationResourceModifier.setDescription("Controls how lair resource calculation is handled after each agitation tier change. Higher values result in greater resources, and therefore more powerful garrisoned troops and better loot.");

    local lairNamedLootChance = pageGeneral.addRangeSetting("LairNamedLootChance", 12, 1, 25, 1.0, "Lair Named Item Chance");
    lairNamedLootChance.setDescription("Determines the base chance for lairs to contain new named items when agitation is incremented.");

    foreach( file in ::IO.enumerateFiles("mod_rpgr_raids/hooks") )
    {
        ::include(file);
    }
});