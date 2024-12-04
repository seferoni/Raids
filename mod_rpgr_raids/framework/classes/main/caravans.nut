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
		local iterations = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject) - 1;

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
		local cargoEnum =  ::Raids.Standard.getFlag("CaravanCargo", _caravanObject);
		local cargoString = ::Raids.Standard.getKey(cargoEnum, descriptors).tolower();
		local actualProduce = produce.filter(@(_index,_value) _value.find(cargoString) != null);

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
		return ::Raids.Standard.constructEntry
		(
			cargoDescriptor,
			cargoDescriptor
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
		if (::World.FactionManager.getFaction(_caravanObject.getFaction()).getType() == ::Const.FactionType.OrientalCityState)
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
			"Famed"
		);
	}

	function createWealthEntry( _caravanObject )
	{
		local wealthDescriptor = ::Raids.Standard.getKey(::Raids.Standard.getFlag("CaravanWealth", _caravanObject), this.getField("WealthDescriptors"));
		return ::Raids.Standard.constructEntry
		(
			"Wealth",
			format("%s (%i)", wealthDescriptor, caravanWealth)
		);
	}

	function formatSituationID( _situationID )
	{
		return _situationID.slice("situation.".len());
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
		local wealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);
		local score = this.Parameters.EliteTroopScore * (wealth - 1);

		if (::Raids.Standard.getFlag("CaravanHasNamedItems", _caravanObject))
		{
			iterations += 1;
		}

		if (::World.FactionManager.getFaction(_caravanObject.getFaction()).getType() == ::Const.FactionType.NobleHouse)
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

	function getField( _fieldName )
	{	// TODO: don't much appreciate that sometimes 'getField' accesses top level fields, and sometimes sub level fields.
		return ::Raids.Database.getTopLevelField("Caravans", _fieldName);
	}

	function getNamedItemKeys()
	{
		return ::Raids.Database.getTopLevelField("Generic", "NamedItemKeys");
	}

	function getReinforcementCount( _caravanObject )
	{
		local wealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);
		local timeOffset = ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays ? this.Parameters.TroopTimeOffset : 0;
		local naiveIterations = wealth + ::Math.rand(wealth - this.WealthDescriptors.Moderate, wealth) + timeOffset;
		return ::Math.min(this.Parameters.MaximumTroopOffset, naiveIterations);
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

	function getTooltipEntries( _caravanObject )
	{
		local entries = [];
		local push = @(_entry) ::Raids.Standard.push(_entry, entries);

		push(this.createCargoEntry(_caravanObject));
		push(this.createWealthEntry(_caravanObject));

		if (!::Raids.Standard.getFlag("CaravanHasNamedItems", _caravanObject))
		{
			return entries;
		}

		push(this.createNamedLootEntry(_caravanObject));
		return entries;
	}

	function initialiseCaravanParameters( _caravanObject, _settlementObject )
	{
		this.setCaravanWealth(_caravanObject, _settlementObject);
		this.setCaravanCargo(_caravanObject, _settlementObject);
		this.setCaravanOrigin(_caravanObject, _settlementObject);
		this.populateInventory(_caravanObject, _settlementObject);

		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("CaravanReinforcementChance"))
		{
			return;
		}

		# Assess wealth for named loot viability.
		local isAbundant = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject) == this.WealthDescriptors.Abundant;

		# Evaluate current time progression for named loot viability.
		local exceedsThreshold = ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays;

		# Flag as viable if the previous conditions obtain.
		if (isAbundant && exceedsThreshold && ::Math.rand(1, 100) <= this.Parameters.NamedItemChance)
		{
			::Raids.Standard.setFlag("CaravanHasNamedItems", true, _caravanObject);
		}

		# Troop reinforcement is partially contingent on named item presence, and so must be called after the prior checks.
		this.reinforceTroops(_caravanObject);
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

		if (::Raids.Standard.getFlag("CaravanWealth", _caravanObject) == wealthDescriptors.Meager)
		{
			return;
		}

		if (::Raids.Standard.getFlag("CaravanCargo", _caravanObject) == wealthDescriptors.Assortment)
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
		local wealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);

		if (::World.FactionManager.getFaction(_caravanObject.getFaction()).getType() == ::Const.FactionType.NobleHouse)
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
			_caravanObject.addToInventory("special/raids_official_document_item");
		}
	}

	function reinforceTroops( _caravanObject )
	{
		local wealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);
		local wealthDescriptors = this.getField("WealthDescriptors");

		if (wealth == wealthDescriptors.Meager)
		{
			return;
		}

		local iterations = this.getReinforcementCount(_caravanObject);
		local factionType = ::World.FactionManager.getFaction(_caravanObject.getFaction()).getType();
		local mundaneTroops = this.createCaravanTroops(factionType);
		this.addTroops(_caravanObject, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, iterations);

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
		this.addTroops(_caravanObject, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, iterations);
	}

	function setCaravanCargo( _caravanObject, _settlementObject )
	{
		local cargoDescriptors = this.getField("CargoDescriptors");
		local randomNumber = ::Math.rand(1, 100);
		local isEligible = @(_value) randomNumber <= _value;

		# Assume default value.
		local cargoType = this.CargoDescriptors.Trade;

		if (isEligible(this.CargoDistribution.Assortment) || _settlementObject.getProduce().len() == 0)
		{
			cargoType = this.CargoDescriptors.Assortment;
		}
		else if (isEligible(this.CargoDistribution.Supplies))
		{
			cargoType = this.CargoDescriptors.Supplies;
		}

		::Raids.Standard.setFlag("CaravanCargo", cargoType, _caravanObject);
	}

	function setCaravanOrigin( _caravanObject, _settlementObject )
	{
		::Raids.Standard.setFlag("CaravanOrigin", _settlementObject.getFaction(), _caravanObject);
	}

	function setCaravanWealth( _caravanObject, _settlementObject )
	{
		local caravanWealth = ::Math.rand(1, 2);

		# Emulating clamp functionality.
		local normalise = @(_value) ::Math.min(::Math.max(_value, this.WealthDescriptors.Meager), this.WealthDescriptors.Abundant);

		if (_settlementObject.isSouthern() || ::World.FactionManager.getFaction(_caravanObject.getFaction()).getType() == ::Const.FactionType.NobleHouse)
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

	function updateOrigin( _caravanObject )
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