local Raids = ::RPGR_Raids;
Raids.Caravans <-
{
	AntagonisticSituations =
	[
		"ambushed_trade_routes",
		"draught",
		"greenskins",
		"mine_cavein",
		"moving_sands",
		"raided",
		"short_on_food",
		"sickness",
		"slave_revolt",
		"snow_storms",
		"warehouse_burned_down"
	],
	CargoDescriptors =
	{
		Supplies = 1,
		Trade = 2,
		Assortment = 3,
		Unassorted = 4
	},
	CargoDistribution =
	{
		Supplies = 50,
		Trade = 100,
		Assortment = 20
	},
	ExcludedGoods =
	[
		"supplies/food_item",
		"supplies/money_item",
		"trade/trading_good_item",
		"supplies/strange_meat_item",
		"supplies/fermented_unhold_heart_item",
		"supplies/black_marsh_stew_item"
	],
	NamedItemKeys =
	[
		"NamedArmors",
		"NamedWeapons",
		"NamedHelmets",
		"NamedShields"
	],
	Parameters =
	{
		EliteTroopNobleOffset = 10,
		EliteTroopTimeOffset = 10,
		EliteTroopScore = 10,
		MaximumSituationOffset = 1,
		MaximumTroopOffset = 9,
		MinimumSituationOffset = -1,
		NamedItemChance = 12,
		ReinforcementThresholdDays = 25,
		SituationDuration = 4,
		SituationMaximumDuration = 16,
		SupplyCaravanDocumentChanceOffset = 35,
		TroopTimeOffset = 1,
		WealthDocumentChanceOffset = 10
	},
	SouthernGoods =
	[
		"supplies/dates_item",
		"supplies/rice_item",
		"trade/silk_item",
		"trade/spices_item",
		"trade/incense_item"
	],
	SynergisticSituations =
	[
		"bread_and_games",
		"full_nets",
		"good_harvest",
		"rich_veins",
		"safe_roads",
		"seasonal_fair",
		"well_supplied"
	],
	Tooltip = 
	{
		Icons = 
		{
			Assortment = "ui/icons/asset_money.png",
			Famed = "ui/icons/special.png",
			Supplies = "ui/icons/asset_food.png"
			Trade = "ui/icons/money.png",
			Unassorted = "ui/icons/bag.png",
			Wealth = "ui/icons/money2.png"
		},
		Template =
		{
			id = 2, 
			type = "hint",
			icon = "",
			text = ""
		}
	}
	TroopTypes =
	{
		Generic = 
		{
			Conventional = ["CaravanGuard"]
		},
		Mercenaries = 
		{
			Conventional = ["Mercenary", "MercenaryLOW", "MercenaryRanged"], 
			Elite = ["HedgeKnight", "MasterArcher", "Swordmaster"]
		},
		NobleHouse = 
		{
			Conventional = ["Arbalester", "Billman", "Footman"],
			Elite = ["Greatsword", "Knight", "Sergeant"]
		},
		OrientalCityState = 
		{
			Conventional = ["Conscript", "ConscriptPolearm", "Gunner"], 
			Elite = ["Assassin", "DesertDevil", "DesertStalker"]
		}
	},
	WealthDescriptors =
	{
		Meager = 1,
		Moderate = 2,
		Plentiful = 3,
		Abundant = 4
	}

	function addToInventory( _caravan, _goodsPool )
	{
		local iterations = Raids.Standard.getFlag("CaravanWealth", _caravan) - 1;

		for( local i = 0; i < iterations; i++ )
		{
			_caravan.addToInventory(_goodsPool[::Math.rand(0, _goodsPool.len() - 1)]);
		}
	}

	function addNamedCargo( _lootTable )
	{
		local namedCargo = this.createNamedLoot(),
		namedItem = ::new(format("scripts/items/%s", namedCargo[::Math.rand(0, namedCargo.len() - 1)]));
		namedItem.onAddedToStash(null);
		_lootTable.push(namedItem);
	}

	function addTroops( _caravan, _troopType, _count )
	{
		for( local i = 0; i < _count; i++ )
		{
			::Const.World.Common.addTroop(_caravan, _troopType, true);
		}
	}

	function createCaravanCargo( _caravan, _settlement )
	{
		local produce = _settlement.getProduce(),
		descriptor = Raids.Standard.getDescriptor(Raids.Standard.getFlag("CaravanCargo", _caravan), this.CargoDescriptors).tolower(),
		actualProduce = produce.filter(@(_index,_value) _value.find(descriptor) != null);

		if (actualProduce.len() != 0)
		{
			return actualProduce;
		}

		local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CargoDescriptors.Assortment : this.CargoDescriptors.Unassorted;
		Raids.Standard.setFlag("CaravanCargo", newCargoType, _caravan);

		if (newCargoType == this.CargoDescriptors.Assortment)
		{
			return this.createNaiveCaravanCargo(_caravan);
		}

		return produce;
	}

	function createCaravanTroops( _wealth, _factionType )
	{
		local troops = [];

		if (_factionType == ::Const.FactionType.NobleHouse)
		{
			troops.extend(this.formatTroopType(this.TroopTypes.NobleHouse.Conventional))
			return troops;
		}

		troops.extend(this.formatTroopType(this.TroopTypes.Mercenaries.Conventional));

		if (_factionType == ::Const.FactionType.OrientalCityState)
		{
			troops.extend(this.formatTroopType(this.TroopTypes.OrientalCityState.Conventional));
		}
		else
		{
			troops.extend(this.formatTroopType(this.TroopTypes.Generic.Conventional));
		}

		return troops;
	}

	function createEliteCaravanTroops( _factionType )
	{
		local troops = [];

		if (_factionType == ::Const.FactionType.NobleHouse)
		{
			troops.extend(this.formatTroopType(this.TroopTypes.NobleHouse.Elite));
			return troops;
		}

		if (_factionType == ::Const.FactionType.OrientalCityState)
		{
			troops.extend(this.formatTroopType(this.TroopTypes.OrientalCityState.Elite));
			return troops;
		}

		troops.extend(this.formatTroopType(this.TroopTypes.Mercenaries.Elite));
		return troops;
	}

	function createNaiveCaravanCargo( _caravan )
	{
		if (::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.OrientalCityState)
		{
			return this.SouthernGoods;
		}

		local exclusionList = clone this.ExcludedGoods;
		exclusionList.extend(this.SouthernGoods);
		local scriptFiles = ::IO.enumerateFiles("scripts/items/trade");
		scriptFiles.extend(::IO.enumerateFiles("scripts/items/supplies"));

		foreach( filePath in exclusionList )
		{
			local index = scriptFiles.find(format("scripts/items/%s", filePath));
			if (index != null) scriptFiles.remove(index);
		}

		local culledString = "scripts/items/",
		goods = scriptFiles.map(@(_stringPath) _stringPath.slice(culledString.len()));
		return goods;
	}

	function createNamedLoot()
	{
		local namedLoot = [];

		foreach( key in this.NamedItemKeys )
		{
			namedLoot.extend(::Const.Items[key]);
		}

		return namedLoot;
	}

	function formatSituationID( _situationID )
	{
		local culledString = "situation.",
		situationString = _situationID.slice(culledString.len());
		return situationString;
	}

	function formatTroopType( _troopsArray )
	{
		local troops = _troopsArray.map(@(_troopString) ::Const.World.Spawn.Troops[_troopString]);
		return troops;
	}

	function getEliteReinforcementCount( _caravan )
	{
		local iterations = 0,  
		wealth = Raids.Standard.getFlag("CaravanWealth", _caravan),
		score = this.Parameters.EliteTroopScore * (wealth - 1);

		if (Raids.Standard.getFlag("CaravanHasNamedItems", _caravan))
		{
			iterations += 1;
		}

		if (::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.NobleHouse)
		{
			score += this.Parameters.EliteTroopNobleOffset;
		}

		if (::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
		{
			score += this.Parameters.EliteTroopTimeOffset;
		}

		if (::Math.rand(1, 100) <= score)
		{
			iterations += 1;
		}

		return iterations;
	}

	function getReinforcementCount( _caravan )
	{	
		# Get caravan wealth value.
		local wealth = Raids.Standard.getFlag("CaravanWealth", _caravan);

		# Get time offset if current time exceeds pre-defined threshold.
		local timeOffset = ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays ? this.Parameters.TroopTimeOffset : 0;

		# Define total troop count based on wealth and time.
		local naiveIterations = wealth + ::Math.rand(wealth - this.WealthDescriptors.Moderate, wealth) + timeOffset;

		# Ensure return value remains short of the pre-defined troop reinforcement ceiling.
		return ::Math.min(this.Parameters.MaximumTroopOffset, naiveIterations);
	}

	function getSituationOffset( _settlement )
	{
		local offset = 0, grossSituations = _settlement.getSituations();

		if (grossSituations.len() == 0)
		{
			return offset;
		}

		local Caravans = this,
		settlementSituations = grossSituations.map(@(_situation) Caravans.formatSituationID(_situation.getID()));

		if (settlementSituations.len() == 0)
		{
			return offset;
		}

		foreach( situation in settlementSituations )
		{
			if (this.SynergisticSituations.find(situation) != null)
			{
				offset += 1;
			}
			else if (this.AntagonisticSituations.find(situation) != null)
			{
				offset -= 1;
			}
		}

		return offset <= 0 ? ::Math.max(this.Parameters.MinimumSituationOffset, offset) : this.Parameters.MaximumSituationOffset;
	}

	function getTooltipEntries( _caravan )
	{
		local entries = [],
		push = @(_entry) entries.push(_entry);

		# Prepare variables in local environment.
		local caravanWealth = Raids.Standard.getFlag("CaravanWealth", _caravan),
		wealthDescriptor = Raids.Standard.getDescriptor(caravanWealth, this.WealthDescriptors), 
		cargoDescriptor = Raids.Standard.getDescriptor(Raids.Standard.getFlag("CaravanCargo", _caravan), this.CargoDescriptors);

		# Create cargo tooltip entry.
		local cargoEntry = clone this.Tooltip.Template;
		cargoEntry.icon = format(this.Tooltip.Icons[cargoDescriptor]);
		cargoEntry.text = format("%s", cargoDescriptor);
		push(cargoEntry);

		# Create wealth tooltip entry.
		local wealthEntry = clone this.Tooltip.Template;
		wealthEntry.icon = this.Tooltip.Icons.Wealth;
		wealthEntry.text = format("%s (%i)", wealthDescriptor, caravanWealth);
		push(wealthEntry);

		if (!Raids.Standard.getFlag("CaravanHasNamedItems", _caravan))
		{
			return entries;
		}

		# Create famed item entry.
		local famedItemEntry = clone this.Tooltip.Template;
		famedItemEntry.icon = this.Tooltip.Icons.Famed;
		famedItemEntry.text = "Famed";
		push(famedItemEntry);

		return entries;
	}

	function initialiseCaravanParameters( _caravan, _settlement )
	{
		this.setCaravanWealth(_caravan, _settlement);
		this.setCaravanCargo(_caravan, _settlement);
		this.setCaravanOrigin(_caravan, _settlement);
		this.populateInventory(_caravan, _settlement);

		if (::Math.rand(1, 100) > Raids.Standard.getSetting("CaravanReinforcementChance"))
		{
			return;
		}

		local isAbundant = Raids.Standard.getFlag("CaravanWealth", _caravan) == this.WealthDescriptors.Abundant,
		exceedsThreshold = ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays;

		if (isAbundant && exceedsThreshold && ::Math.rand(1, 100) <= this.Parameters.NamedItemChance)
		{
			Raids.Standard.setFlag("CaravanHasNamedItems", true, _caravan);
		}

		this.reinforceTroops(_caravan, _settlement);
	}

	function isPartyInitialised( _party )
	{
		local isInitialised = @(_flag) Raids.Standard.getFlag(_flag, _party) != false;
		return isInitialised("CaravanWealth") && isInitialised("CaravanCargo") && isInitialised("CaravanOrigin");
	}

	function isPartyViable( _party )
	{
		return Raids.Standard.getFlag("IsCaravan", _party);
	}

	function populateInventory( _caravan, _settlement )
	{
		if (Raids.Standard.getFlag("CaravanWealth", _caravan) == this.WealthDescriptors.Meager)
		{
			return;
		}

		if (Raids.Standard.getFlag("CaravanCargo", _caravan) == this.CargoDescriptors.Assortment)
		{
			this.addToInventory(_caravan, this.createNaiveCaravanCargo(_caravan));
			return;
		}

		this.addToInventory(_caravan, this.createCaravanCargo(_caravan, _settlement));
		this.populateOfficialDocuments(_caravan);
	}

	function populateOfficialDocuments( _caravan )
	{
		local documentChance = Raids.Standard.getSetting("OfficialDocumentDropChance"),
		wealth = Raids.Standard.getFlag("CaravanWealth", _caravan);

		if (::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.NobleHouse)
		{
			documentChance += this.Parameters.SupplyCaravanDocumentChanceOffset;
		}

		if (wealth != this.WealthDescriptors.Meager)
		{
			documentChance += wealth * this.Parameters.WealthDocumentChanceOffset;
		}

		local iterations = 0;

		if (documentChance > 100)
		{
			iterations += 1;
		}

		if (::Math.rand(1, 100) <= documentChance - (iterations * 100))
		{
			iterations += 1;
		}

		if (iterations == 0)
		{
			return;
		}

		for( local i = 0; i < iterations; i++ )
		{
			_caravan.addToInventory("special/official_document_item");
		}
	}

	function reinforceTroops( _caravan, _settlement )
	{
		local wealth = Raids.Standard.getFlag("CaravanWealth", _caravan);

		if (wealth == this.WealthDescriptors.Meager)
		{
			return;
		}

		local iterations = this.getReinforcementCount(_caravan),
		factionType = ::World.FactionManager.getFaction(_caravan.getFaction()).getType(),
		mundaneTroops = this.createCaravanTroops(wealth, factionType);
		this.addTroops(_caravan, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, iterations);

		if (wealth < this.WealthDescriptors.Plentiful)
		{
			return;
		}

		if (::World.getTime().Days < this.Parameters.ReinforcementThresholdDays)
		{
			return;
		}

		iterations = this.getEliteReinforcementCount(_caravan);

		if (iterations == 0)
		{
			return;
		}

		local eliteTroops = this.createEliteCaravanTroops(factionType);
		this.addTroops(_caravan, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, iterations);
	}

	function setCaravanCargo( _caravan, _settlement )
	{
		local randomNumber = ::Math.rand(1, 100),
		diceRoll = @(_value) randomNumber <= _value,
		cargoType = this.CargoDescriptors.Trade;

		if (diceRoll(this.CargoDistribution.Assortment) || _settlement.getProduce().len() == 0)
		{
			cargoType = this.CargoDescriptors.Assortment;
		}
		else if (diceRoll(this.CargoDistribution.Supplies))
		{
			cargoType = this.CargoDescriptors.Supplies;
		}

		Raids.Standard.setFlag("CaravanCargo", cargoType, _caravan);
	}

	function setCaravanOrigin( _caravan, _settlement )
	{
		Raids.Standard.setFlag("CaravanOrigin", _settlement.getFaction(), _caravan);
	}

	function setCaravanWealth( _caravan, _settlement )
	{
		local caravanWealth = ::Math.rand(1, 2),
		normalise = @(_value) ::Math.min(::Math.max(_value, this.WealthDescriptors.Meager), this.WealthDescriptors.Abundant);

		if (_settlement.isSouthern() || ::World.FactionManager.getFaction(_caravan.getFaction()).getType() == ::Const.FactionType.NobleHouse)
		{
			caravanWealth += 1;
		}

		if (_settlement.getSize() >= 3)
		{
			caravanWealth += 1;
		}

		caravanWealth += this.getSituationOffset(_settlement);
		Raids.Standard.setFlag("CaravanWealth", normalise(caravanWealth), _caravan);
	}

	function updateOrigin( _caravan )
	{
		local settlementIndex = Raids.Standard.getFlag("CaravanOrigin", _caravan);

		if (!(settlementIndex in ::World.FactionManager.m.Factions))
		{
			return;
		}

		local settlementFaction = ::World.FactionManager.getFaction(settlementIndex);

		if (settlementFaction == null)
		{
			return;
		}

		local settlement = settlementFaction.getSettlements()[0];

		if (!settlement.isAlive())
		{
			return;
		}

		if (settlement.hasSituation("situation.ambushed_trade_routes"))
		{
			local situation = settlement.getSituationByID("situation.ambushed_trade_routes"),
			duration = situation.getValidUntil() + this.Parameters.SituationDuration;
			situation.setValidForDays(::Math.min(this.Parameters.SituationMaximumDuration, duration));
			return;
		}

		settlement.addSituation(::new("scripts/entity/world/settlements/situations/ambushed_trade_routes_situation"), this.Parameters.SituationDuration);
	}
};