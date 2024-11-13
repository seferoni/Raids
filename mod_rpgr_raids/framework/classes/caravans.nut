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
		local descriptor = ::Raids.Standard.getDescriptor(::Raids.Standard.getFlag("CaravanCargo", _caravanObject), this.CargoDescriptors).tolower();
		local actualProduce = produce.filter(@(_index,_value) _value.find(descriptor) != null);

		if (actualProduce.len() != 0)
		{
			return actualProduce;
		}

		local newCargoType = ::Math.rand(1, 100) <= 50 ? this.CargoDescriptors.Assortment : this.CargoDescriptors.Unassorted;
		::Raids.Standard.setFlag("CaravanCargo", newCargoType, _caravanObject);

		if (newCargoType == this.CargoDescriptors.Assortment)
		{
			return this.createNaiveCaravanCargo(_caravanObject);
		}

		return produce;
	}

	function createCaravanTroops( _factionType )
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

	function createCargoEntry( _caravanObject )
	{	// TODO: rewrite this to use our new constructEntry method!
		# Get cargo descriptor from enumerated cargo value.
		local cargoDescriptor = ::Raids.Standard.getDescriptor(::Raids.Standard.getFlag("CaravanCargo", _caravanObject), this.CargoDescriptors);

		# Create entry.
		local entry = clone this.Tooltip.Template;
		entry.icon = format(this.Tooltip.Icons[cargoDescriptor]);
		entry.text = format("%s", cargoDescriptor);
		return entry;
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

		foreach( key in this.NamedItemKeys )
		{
			namedLoot.extend(::Const.Items[key]);
		}

		return namedLoot;
	}

	function createNamedLootEntry( _caravanObject )
	{
		local entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.Famed;
		entry.text = "Famed";
		return entry;
	}

	function createWealthEntry( _caravanObject )
	{
		# Get wealth and corresponding 'descriptor' key.
		local caravanWealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject),
		wealthDescriptor = ::Raids.Standard.getDescriptor(caravanWealth, this.WealthDescriptors);

		# Create entry.
		local entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.Wealth;
		entry.text = format("%s (%i)", wealthDescriptor, caravanWealth);
		return entry;
	}

	function formatSituationID( _situationID )
	{
		local culledString = "situation.",
		situationString = _situationID.slice(culledString.len());
		return situationString;
	}

	function getExcludedGoodsList()
	{
		local excludedGoods = clone ::Raids.Database.Caravans.Goods.Excluded;
		excludedGoods.extend(::Raids.Database.Caravans.Goods.Southern);
		return excludedGoods;
	}

	function formatTroopType( _troopArray )
	{
		local troops = _troopArray.map(@(_troopString) ::Const.World.Spawn.Troops[_troopString]);
		return troops;
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

	function getReinforcementCount( _caravanObject )
	{
		local wealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);
		local timeOffset = ::World.getTime().Days >= this.Parameters.ReinforcementThresholdDays ? this.Parameters.TroopTimeOffset : 0;
		local naiveIterations = wealth + ::Math.rand(wealth - this.WealthDescriptors.Moderate, wealth) + timeOffset;
		return ::Math.min(this.Parameters.MaximumTroopOffset, naiveIterations);
	}

	function getSituationOffset( _settlementObject )
	{
		local offset = 0, grossSituations = _settlementObject.getSituations();

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
		if (::Raids.Standard.getFlag("CaravanWealth", _caravanObject) == this.WealthDescriptors.Meager)
		{
			return;
		}

		if (::Raids.Standard.getFlag("CaravanCargo", _caravanObject) == this.CargoDescriptors.Assortment)
		{
			this.addToInventory(_caravanObject, this.createNaiveCaravanCargo(_caravanObject));
			return;
		}

		this.addToInventory(_caravanObject, this.createCaravanCargo(_caravanObject, _settlementObject));
		this.populateOfficialDocuments(_caravanObject);
	}

	function populateOfficialDocuments( _caravanObject )
	{
		local documentChance = ::Raids.Standard.getParameter("OfficialDocumentDropChance"),
		wealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);

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
			_caravanObject.addToInventory("special/official_document_item");
		}
	}

	function reinforceTroops( _caravanObject )
	{
		local wealth = ::Raids.Standard.getFlag("CaravanWealth", _caravanObject);

		# Low wealth caravans are exempt from reinforcement.
		if (wealth == this.WealthDescriptors.Meager)
		{
			return;
		}

		# Calculate reinforcement count based on wealth and time.
		local iterations = this.getReinforcementCount(_caravanObject);

		# Get faction type.
		local factionType = ::World.FactionManager.getFaction(_caravanObject.getFaction()).getType();

		# Get eligible troop types.
		local mundaneTroops = this.createCaravanTroops(factionType);

		# Add troops.
		this.addTroops(_caravanObject, {Type = mundaneTroops[::Math.rand(0, mundaneTroops.len() - 1)]}, iterations);

		if (wealth < this.WealthDescriptors.Plentiful)
		{
			return;
		}

		# Evaluate time progression for elite troop reinforcement eligibility.
		if (::World.getTime().Days < this.Parameters.ReinforcementThresholdDays)
		{
			return;
		}

		iterations = this.getEliteReinforcementCount(_caravanObject);

		if (iterations == 0)
		{
			return;
		}

		# Get eligible 'elite' troop types.
		local eliteTroops = this.createEliteCaravanTroops(factionType);

		# Add troops.
		this.addTroops(_caravanObject, {Type = eliteTroops[::Math.rand(0, eliteTroops.len() - 1)]}, iterations);
	}

	function setCaravanCargo( _caravanObject, _settlementObject )
	{
		local randomNumber = ::Math.rand(1, 100),
		diceRoll = @(_value) randomNumber <= _value;

		# Assume default value.
		local cargoType = this.CargoDescriptors.Trade;

		if (diceRoll(this.CargoDistribution.Assortment) || _settlementObject.getProduce().len() == 0)
		{
			cargoType = this.CargoDescriptors.Assortment;
		}
		else if (diceRoll(this.CargoDistribution.Supplies))
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