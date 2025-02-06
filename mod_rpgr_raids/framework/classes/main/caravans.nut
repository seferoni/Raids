::Raids.Caravans <-
{
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
	}

	function addNamedCargo( _lootArray )
	{
		local namedCargo = this.createNamedLoot();
		local namedItem = ::new(format("scripts/items/%s", namedCargo[::Math.rand(0, namedCargo.len() - 1)]));
		namedItem.onAddedToStash(null);
		_lootArray.push(namedItem);
	}

	function addToInventory( _caravanObject, _goodsArray )
	{
		local iterations = this.getCaravanProperties(_caravanObject).Wealth - 1;

		for( local i = 0; i < iterations; i++ )
		{
			_caravanObject.addToInventory(_goodsArray[::Math.rand(0, _goodsArray.len() - 1)]);
		}
	}

	function addTroops( _caravanObject, _troopType, _count )
	{
		for( local i = 0; i < _count; i++ )
		{
			::Const.World.Common.addTroop(_caravanObject, _troopType, true);
		}
	}

	function createCaravanCargo( _caravanObject, _settlementObject )
	{
		local produce = _settlementObject.getProduce();
		local descriptors = this.getField("CargoDescriptors");
		local cargoEnum =  this.getCaravanProperties(_caravanObject).Cargo;
		local cargoKey = ::Raids.Standard.getKey(cargoEnum, descriptors).tolower();
		local actualProduce = produce.filter(@(_index,_value) _value.find(cargoKey) != null);

		if (actualProduce.len() != 0)
		{
			return actualProduce;
		}

		local newCargoType = ::Math.rand(1, 100) <= 50 ? descriptors.Assortment : descriptors.Unassorted;
		::Raids.Standard.setFlag("CaravanCargo", newCargoType, _caravanObject);

		if (newCargoType == descriptors.Assortment)
		{
			return this.createNaiveCaravanCargo(_caravanObject);
		}

		return produce;
	}

	function createCaravanTroops( _factionType )
	{
		local troops = [];
		local troopTypes = this.getField("Troops");

		if (_factionType == ::Const.FactionType.NobleHouse)
		{
			troops.extend(troopTypes.NobleHouse.Conventional)
			return troops;
		}

		troops.extend(troopTypes.Mercenaries.Conventional);

		if (_factionType == ::Const.FactionType.OrientalCityState)
		{
			troops.extend(troopTypes.OrientalCityState.Conventional);
		}
		else
		{
			troops.extend(troopTypes.Generic.Conventional);
		}

		return troops;
	}

	function createCargoEntry( _caravanObject )
	{
		local cargoDescriptor = ::Raids.Standard.getKey(::Raids.Standard.getFlag("CaravanCargo", _caravanObject), this.getField("CargoDescriptors"));
		local cargoString = ::Raids.Strings.Caravans[format("Cargo%s", cargoDescriptor)];
		return ::Raids.Standard.constructEntry
		(
			cargoDescriptor,
			cargoString
		);
	}

	function createEliteCaravanTroops( _factionType )
	{
		local troops = [];
		local troopTypes = this.getField("Troops");

		if (_factionType == ::Const.FactionType.NobleHouse)
		{
			troops.extend(troopTypes.NobleHouse.Elite);
			return troops;
		}

		if (_factionType == ::Const.FactionType.OrientalCityState)
		{
			troops.extend(troopTypes.OrientalCityState.Elite);
			return troops;
		}

		troops.extend(troopTypes.Mercenaries.Elite);
		return troops;
	}

	function createNaiveCaravanCargo( _caravanObject )
	{
		if (this.getFactionType(_caravanObject) == ::Const.FactionType.OrientalCityState)
		{
			return this.SouthernGoods;
		}

		local exclusionList = this.getExcludedGoodsList();
		local scriptFiles = ::IO.enumerateFiles("scripts/items/trade");
		scriptFiles.extend(::IO.enumerateFiles("scripts/items/supplies"));

		foreach( filePath in exclusionList )
		{
			local index = scriptFiles.find(format("scripts/items/%s", filePath));

			if (index != null)
			{
				scriptFiles.remove(index);
			}
		}

		local goods = scriptFiles.map(@(_stringPath) _stringPath.slice("scripts/items/".len()));
		return goods;
	}

	function createNamedLoot()
	{
		local namedLoot = [];

		foreach( key in this.getNamedItemKeys() )
		{
			namedLoot.extend(::Const.Items[key]);
		}

		return namedLoot;
	}

	function createNamedLootEntry( _caravanObject )
	{
		return ::Raids.Standard.constructEntry
		(
			"Special",
			::Raids.Strings.Generic.Named
		);
	}

	function createWealthEntry( _caravanObject )
	{
		local caravanWealth = this.getCaravanProperties(_caravanObject).Wealth;
		local wealthDescriptor = ::Raids.Standard.getKey(caravanWealth, this.getField("WealthDescriptors"));
		local wealthString = ::Raids.Strings.Caravans[format("Wealth%s", wealthDescriptor)];
		return ::Raids.Standard.constructEntry
		(
			"Wealth",
			format("%s (%i)", wealthString, caravanWealth)
		);
	}

	function locateCaravanOnAction( _settlementObject )
	{
		local grossEntities = ::World.getAllEntitiesAtPos(_settlementObject.getPos(), 1.0);
		local caravan = null;

		foreach( entity in grossEntities )
		{
			if (this.isPartyViable(entity) && !this.isPartyInitialised(entity))
			{
				caravan = entity;
			}
		}

		return caravan;
	}

	function formatSituationID( _situationID )
	{
		return _situationID.slice("situation.".len());
	}

	function getCaravanProperties( _caravanObject )
	{
		local properties = {};
		properties.Wealth <- ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);
		properties.Cargo <- ::Raids.Standard.getFlag("CaravanCargo", _caravanObject);
		properties.Origin <- ::Raids.Standard.getFlag("CaravanOrigin", _caravanObject);

		foreach( propertyKey, propertyValue in properties )
		{
			if (propertyValue == false)
			{
				::Raids.Standard.log(format(::Raids.Strings.Debug.InvalidCaravanProperties, _caravanObject.getID()));
				break;
			}
		}

		return properties;
	}

	function getExcludedGoodsList()
	{
		local goods = this.getField("Goods");
		local excludedGoods = clone goods.Excluded;
		excludedGoods.extend(goods.Southern);
		return excludedGoods;
	}

	function getEliteReinforcementCount( _caravanObject )
	{
		local iterations = 0;
		local wealth = this.getCaravanProperties(_caravanObject).Wealth;
		local score = this.Parameters.EliteTroopScore * (wealth - 1);

		if (this.getNamedItemCarrierState(_caravanObject))
		{
			iterations += 1;
		}

		if (this.getFactionType(_caravanObject) == ::Const.FactionType.NobleHouse)
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

	function getFactionType( _caravanObject )
	{
		local worldFaction = ::World.FactionManager.getFaction(_caravanObject.getFaction());
		return worldFaction.getType();
	}

	function getField( _fieldName )
	{
		return ::Raids.Database.getField("Caravans", _fieldName);
	}

	function getNamedItemCarrierState( _caravanObject )
	{
		return ::Raids.Standard.getFlag("NamedItemCarrier", _caravanObject);
	}

	function getNamedItemKeys()
	{
		return ::Raids.Database.getField("Generic", "NamedItemKeys");
	}

	function getReinforcementCount( _caravanObject )
	{
		local wealth = this.getCaravanProperties(_caravanObject).Wealth;
		local iterations = wealth + ::Math.rand(wealth - this.getField("WealthDescriptors").Moderate, wealth) + timeOffset;

		if (::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays)
		{
			iterations += this.Parameters.TroopTimeOffset;
		}

		return ::Math.min(this.Parameters.MaximumTroopOffset, iterations);
	}

	function getSituationOffset( _settlementObject )
	{
		local offset = 0;
		local grossSituations = _settlementObject.getSituations();

		if (grossSituations.len() == 0)
		{
			return offset;
		}

		local settlementSituations = grossSituations.map(@(_situation) ::Raids.Caravans.formatSituationID(_situation.getID()));

		if (settlementSituations.len() == 0)
		{
			return offset;
		}

		foreach( situation in settlementSituations )
		{
			if (this.getField("SynergisticSituations").find(situation) != null)
			{
				offset += 1;
			}
			else if (this.getField("AntagonisticSituations").find(situation) != null)
			{
				offset -= 1;
			}
		}

		return offset <= 0 ? ::Math.max(this.Parameters.MinimumSituationOffset, offset) : this.Parameters.MaximumSituationOffset;
	}

	function getTooltipEntries( _caravanObject )
	{
		local entries = [];
		local push = @(_entry) ::Raids.Standard.push(_entry, entries);

		push(this.createCargoEntry(_caravanObject));
		push(this.createWealthEntry(_caravanObject));

		if (!this.getNamedItemCarrierState(_caravanObject))
		{
			return entries;
		}

		push(this.createNamedLootEntry(_caravanObject));
		return entries;
	}

	function initialiseCaravanCargo( _caravanObject, _settlementObject )
	{
		local cargoDescriptors = this.getField("CargoDescriptors");
		local randomNumber = ::Math.rand(1, 100);
		local isEligible = @(_value) randomNumber <= _value;

		# Assume default value.
		local cargoType = cargoDescriptors.Trade;

		if (isEligible(cargoDescriptors.Assortment) || _settlementObject.getProduce().len() == 0)
		{
			cargoType = cargoDescriptors.Assortment;
		}
		else if (isEligible(cargoDescriptors.Supplies))
		{
			cargoType = cargoDescriptors.Supplies;
		}

		this.setCaravanCargo(cargoType, _caravanObject);
	}

	function initialiseCaravanOrigin( _caravanObject, _settlementObject )
	{
		this.setCaravanOrigin(_settlementObject.getFaction(), _caravanObject);
	}

	function initialiseCaravanParameters( _caravanObject, _settlementObject )
	{
		this.initialiseCaravanWealth(_caravanObject, _settlementObject);
		this.initialiseCaravanCargo(_caravanObject, _settlementObject);
		this.initialiseCaravanOrigin(_caravanObject, _settlementObject);
		this.populateInventory(_caravanObject, _settlementObject);

		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("CaravanReinforcementChance"))
		{
			return;
		}

		# Assess wealth for named loot viability.
		local isAbundant = this.getCaravanProperties(_caravanObject).Wealth == this.getField("WealthDescriptors").Abundant;

		# Evaluate current time progression for named loot viability.
		local exceedsThreshold = ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays;

		# Flag as viable if the previous conditions obtain.
		if (isAbundant && exceedsThreshold && ::Math.rand(1, 100) <= this.Parameters.NamedItemChance)
		{
			this.setNamedItemCarrierState(true, _caravanObject);
		}

		# Troop reinforcement is partially contingent on named item presence, and so must be called after the prior checks.
		this.reinforceTroops(_caravanObject);
	}

	function initialiseCaravanWealth( _caravanObject, _settlementObject )
	{
		local caravanWealth = ::Math.rand(1, 2);
		local wealthDescriptors = this.getField("WealthDescriptors");

		# Emulating clamp functionality.
		local normalise = @(_value) ::Math.min(::Math.max(_value, wealthDescriptors.Meager), wealthDescriptors.Abundant);

		if (_settlementObject.isSouthern() || this.getFactionType(_caravanObject) == ::Const.FactionType.NobleHouse)
		{
			caravanWealth += 1;
		}

		if (_settlementObject.getSize() >= 3)
		{
			caravanWealth += 1;
		}

		caravanWealth += this.getSituationOffset(_settlementObject);
		::Raids.Standard.setFlag("CaravanWealth", normalise(caravanWealth), _caravanObject);
	}

	function isPartyInitialised( _partyObject )
	{
		local isInitialised = @(_flag) ::Raids.Standard.getFlag(_flag, _partyObject) != false;
		return isInitialised("CaravanWealth") && isInitialised("CaravanCargo") && isInitialised("CaravanOrigin");
	}

	function isPartyViable( _partyObject )
	{
		return ::Raids.Standard.getFlag("IsCaravan", _partyObject);
	}

	function populateInventory( _caravanObject, _settlementObject )
	{
		local wealthDescriptors = this.getField("WealthDescriptors");
		local cargoDescriptors = this.getField("CargoDescriptors");
		local caravanProperties = this.getCaravanProperties(_caravanObject);

		if (caravanProperties.Wealth == wealthDescriptors.Meager)
		{
			return;
		}

		if (caravanProperties.Cargo == cargoDescriptors.Assortment)
		{
			this.addToInventory(_caravanObject, this.createNaiveCaravanCargo(_caravanObject));
			return;
		}

		this.addToInventory(_caravanObject, this.createCaravanCargo(_caravanObject, _settlementObject));
		this.populateOfficialDocuments(_caravanObject);
	}

	function populateOfficialDocuments( _caravanObject )
	{
		local documentChance = ::Raids.Standard.getParameter("OfficialDocumentDropChance");
		local wealth = this.getCaravanProperties(_caravanObject).Wealth;

		if (this.getFactionType(_caravanObject) == ::Const.FactionType.NobleHouse)
		{
			documentChance += this.Parameters.SupplyCaravanDocumentChanceOffset;
		}

		if (wealth != this.getField("WealthDescriptors").Meager)
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
			_caravanObject.addToInventory("special/raids_official_document_item");
		}
	}

	function reinforceTroops( _caravanObject )
	{
		local wealth = this.getCaravanProperties(_caravanObject).Wealth;
		local wealthDescriptors = this.getField("WealthDescriptors");

		if (wealth == wealthDescriptors.Meager)
		{
			return;
		}

		local iterations = this.getReinforcementCount(_caravanObject);
		local factionType = this.getFactionType(_caravanObject);
		local mundaneTroops = this.createCaravanTroops(factionType);
		local troopType =
		{
			Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]
		};
		this.addTroops(_caravanObject, troopType, iterations);

		if (wealth < wealthDescriptors.Plentiful)
		{
			return;
		}

		if (::World.getTime().Days < this.Parameters.ReinforcementThresholdDays)
		{
			return;
		}

		iterations = this.getEliteReinforcementCount(_caravanObject);

		if (iterations == 0)
		{
			return;
		}

		local eliteTroops = this.createEliteCaravanTroops(factionType);
		troopType.Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)];
		this.addTroops(_caravanObject, troopType, iterations);
	}

	function setCaravanCargo( _cargoEnum, _caravanObject )
	{
		::Raids.Standard.setFlag("CaravanCargo", _cargoEnum, _caravanObject);
	}

	function setCaravanOrigin( _caravanObject, _settlementObject )
	{
		::Raids.Standard.setFlag("CaravanOrigin", _settlementObject.getFaction(), _caravanObject);
	}

	function setCaravanWealth( _wealthEnum, _caravanObject )
	{
		::Raids.Standard.setFlag("CaravanWealth", _wealthEnum, _caravanObject);
	}

	function setNamedItemCarrierState( _boolean, _caravanObject )
	{
		::Raids.Standard.setFlag("NamedItemCarrier", _boolean, _caravanObject);
	}

	function updateOriginOnCombatStart( _caravanObject )
	{
		local settlementIndex = ::Raids.Standard.getFlag("CaravanOrigin", _caravanObject);

		# Edge-case handling.
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

		local situation = settlement.getSituationByID("situation.ambushed_trade_routes");

		if (situation != null)
		{
			situation.setValidForDays(::Math.min(this.Parameters.SituationMaximumDuration, situation.getValidUntil() + this.Parameters.SituationDuration));
			return;
		}

		settlement.addSituation(::new("scripts/entity/world/settlements/situations/ambushed_trade_routes_situation"), this.Parameters.SituationDuration);
	}
};