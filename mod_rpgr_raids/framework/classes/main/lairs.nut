::Raids.Lairs <-
{
	Parameters =
	{
		AgitationDecayDaysCeiling = 7,
		MaximumLootOffset = 3,
		NamedItemChancePerAgitationTier = 13.33,
		NamedItemRemovalChanceOnSpawn = 90,
		PassiveOfficialDocumentCountCeiling = 2,
		ResourcesCeiling = 700,
		ResourceModifierCeiling = 0.25,
		ResourceModifierLowerBound = 200,
		ResourceModifierUpperBound = 350,
		SpawnTimeOffsetInterval = -50.0
	}

	function addLoot( _lootTable, _locationObject )
	{
		local count = this.getAgitation(_locationObject);

		if (count == false)
		{
			count = ::Math.rand(1, this.Parameters.PassiveOfficialDocumentCountCeiling);
		}

		for( local i = 0; i < count; i++ )
		{
			_lootTable.push(::new("scripts/items/special/raids_official_document_item"));
		}
	}

	function createAgitationEntry( _lairObject )
	{
		local agitation = this.getAgitation(_lairObject);
		local descriptors = this.getField("AgitationDescriptors");
		local textColour = ::Raids.Standard.Colour[agitation == descriptors.Relaxed ? "Green" : "Red"];
		return ::Raids.Standard.constructEntry
		(
			agitation == descriptors.Relaxed ? "Relaxed" : "Agitated",
			::Raids.Standard.colourWrap(format("%s (%i)", ::Raids.Standard.getKey(agitation, descriptors), agitation), textColour)
		);
	}

	function createNaiveNamedLoot()
	{
		local namedLoot = [];

		foreach( key in this.getNamedItemKeys() )
		{
			namedLoot.extend(::Const.Items[key]);
		}

		return namedLoot;
	}

	function createNamedLoot( _lairObject )
	{
		if (::Math.rand(1, 100) > ::Raids.Standard.getParameter("FactionSpecificNamedLootChance"))
		{
			return this.createNaiveNamedLoot();
		}

		local namedLoot = [];
		local keys = this.getNamedItemKeys().filter(@(_index, _key) _lairObject.m[format("%sList", _key)] != null);

		foreach( key in keys )
		{
			namedLoot.extend(_lairObject.m[format("%sList", key)]);
		}

		if (namedLoot.len() == 0)
		{
			return this.createNaiveNamedLoot();
		}

		return namedLoot;
	}

	function createResourcesEntry( _lairObject )
	{
		local resources = _lairObject.getResources();
		return ::Raids.Standard.constructEntry
		(
			"Resources",
			format(::Raids.Strings.Generic.ResourcesCount, ::Raids.Standard.colourWrap(resources, ::Raids.Standard.Colour.Green))
		);
	}

	function createTimerEntry( _lairObject )
	{
		local agitation = this.getAgitation(_lairObject);
		local lastUpdateDays = ::Raids.Standard.getFlag("LastAgitationUpdate", _lairObject);

		if (lastUpdateDays == false || agitation == this.getField("AgitationDescriptors").Relaxed)
		{
			return null;
		}

		local timeDifference = (lastUpdateDays + this.getAgitationDecayInterval(_lairObject)) - ::World.getTime().Days;
		return ::Raids.Standard.constructEntry
		(
			"Time",
			format("%s %s", ::Raids.Standard.colourWrap(timeDifference, ::Raids.Standard.Colour.Red), ::Raids.Strings.Generic.Days)
		);
	}

	function depopulateNamedLoot( _lairObject, _chance = 100 )
	{
		if (_lairObject.getLoot().isEmpty())
		{
			return;
		}

		local stash = _lairObject.getLoot();
		local loot = stash.getItems().filter(@(_index, _item) _item != null && _item.isItemType(::Const.Items.ItemType.Named));

		foreach( item in loot )
		{
			if (::Math.rand(1, 100) <= _chance)
			{
				stash.remove(item);
			}
		}
	}

	function getAgitation( _lairObject )
	{	// TODO: this should log an error if uninitialised!
		return ::Raids.Standard.getFlag("Agitation", _lairObject);
	}

	function getAgitationDecayInterval( _lairObject )
	{
		local agitation = this.getAgitation(_lairObject);

		if (agitation <= this.getField("AgitationDescriptors").Cautious)
		{
			return this.Parameters.AgitationDecayDaysCeiling + ::Raids.Edicts.getAgitationDecayOffset(_lairObject);
		}

		local decayInterval = (agitation * -2) + 10;
		return decayInterval + ::Raids.Edicts.getAgitationDecayOffset(_lairObject);
	}

	function getBaseResourceModifier( _resources )
	{
		# The arbitrary coefficients and constants used here are calibrated to ensure smooth scaling behaviour between resource breakpoints.
		local modifier = 1.0;

		if (_resources <= this.Parameters.ResourceModifierLowerBound)
		{
			return modifier;
		}

		if (_resources <= this.Parameters.ResourceModifierUpperBound)
		{
			modifier = -0.005 * _resources + 2.0;
		}
		else
		{
			modifier = this.Parameters.ResourceModifierCeiling;
		}

		return modifier;
	}

	function getCandidateAtPosition( _position )
	{
		local entities = ::World.getAllEntitiesAndOneLocationAtPos(_position, 1.0);
		local lairs = entities.filter(function( _index, _entity )
		{
			if (!::isKindOf(_entity, "location"))
			{
				return false;
			}
			else if (!::Raids.Lairs.isLocationTypeViable(_entity.getLocationType()))
			{
				return false;
			}

			if (::Raids.Lairs.isActiveContractLocation(_entity))
			{
				return false;
			}

			return true;
		});

		if (lairs.len() == 0)
		{
			return null;
		}

		return lairs[0];
	}

	function getCandidateByContract( _contract )
	{
		if (!("Destination" in _contract.m))
		{
			return null;
		}

		local candidate = _contract.m.Destination;

		if (candidate == null || candidate.isNull())
		{
			return null;
		}

		if (!::isKindOf(candidate.get(), "location"))
		{
			return null;
		}

		if (!this.isLocationTypeViable(candidate.getLocationType()))
		{
			return null;
		}

		return candidate;
	}

	function getCandidatesByFaction( _faction )
	{
		local lairs = [];

		if (_faction.getSettlements().len() == 0)
		{
			return lairs;
		}

		lairs.extend(_faction.getSettlements().filter(function( _index, _location )
		{
			if (!::Raids.Lairs.isLocationViable(_location, true, true))
			{
				return false;
			}

			return true;
		}));

		return lairs;
	}

	function getCandidatesWithin( _tile, _distance = 6 )
	{
		local lairs = ::World.EntityManager.getLocations().filter(function( _index, _location )
		{
			if (!::Raids.Lairs.isLocationViable(_location))
			{
				return false;
			}

			if (_tile.getDistanceTo(_location.getTile()) > _distance)
			{
				return false;
			}

			return true;
		});

		return lairs;
	}

	function getFactionKey( _lairObject )
	{
		local typeID = _lairObject.getTypeID();

		foreach( overrideTable in this.getField("Overrides") )
		{
			if (overrideTable.TypeID == typeID)
			{
				return overrideTable.Faction;
			}
		}

		return this.getFactionKeyFromType(this.getFactionType(_lairObject));
	}

	function getFactionKeyFromType( _factionType )
	{
		foreach( factionName, factionEnum in ::Const.FactionType )
		{
			if (factionEnum == _factionType)
			{
				return factionName;
			}
		}
	}

	function getFactionType( _lairObject )
	{
		return ::World.FactionManager.getFaction(_lairObject.getFaction()).getType();
	}

	function getField( _fieldName )
	{
		return ::Raids.Database.getField("Lairs", _fieldName);
	}

	function getMoneyCount( _lairObject )
	{
		return _lairObject.getResources();
	}

	function getNaiveNamedLootChance( _lairObject )
	{
		# The arbitrary coefficients and constants used here are taken verbatim from the vanilla codebase.
		local tile = _lairObject.getTile();
		local settlement = this.getSettlementClosestTo(tile);
		return (_lairObject.getResources() + tile.getDistanceTo(settlement.getTile()) * 4) / 5.0 - 37.0;
	}

	function getNamedItemKeys()
	{
		return ::Raids.Database.getField("Generic", "NamedItemKeys");
	}

	function getNamedLootChance( _lairObject )
	{
		local baseChance = ::Raids.Standard.getFlag("BaseNamedItemChance", _lairObject);
		local agitation = this.getAgitation(_lairObject);
		return baseChance + ((agitation - 1) * this.Parameters.NamedItemChancePerAgitationTier);
	}

	function getPartyResources( _lairObject )
	{
		local baseResourceModifier = this.getBaseResourceModifier(::Raids.Standard.getFlag("BaseResources", _lairObject));
		local configurableModifier = ::Raids.Standard.getPercentageSetting("RoamerResourceModifier");
		return _lairObject.getResources() * this.getTimeModifier() * baseResourceModifier * configurableModifier;
	}

	function getResourcesByAgitation( _lairObject )
	{
		local agitation = this.getAgitation(_lairObject);
		local baseResources = ::Raids.Standard.getFlag("BaseResources", _lairObject);
		local configurableModifier = ::Raids.Standard.getPercentageSetting("AgitationResourceModifier");

		# Create a modifier meant to modulate resource scaling behaviour at both extremes.
		local interpolatedModifier = -0.0006 * baseResources + 0.6;
		return ::Math.floor(baseResources + (interpolatedModifier * (agitation - 1) * configurableModifier * baseResources));
	}

	function getSettlementClosestTo( _tile )
	{
		local closestSettlement = null;
		local closestDistance = 9000;

		foreach( settlement in ::World.EntityManager.getSettlements() )
		{
			local distance = _tile.getDistanceTo(settlement.getTile());

			if (distance < closestDistance)
			{
				closestDistance = distance;
				closestSettlement = settlement;
			}
		}

		return closestSettlement;
	}

	function getSpawnTimeOffset( _lairObject )
	{
		local offset = 0.0;
		local agitation = this.getAgitation(_lairObject);

		if (agitation == this.getField("AgitationDescriptors").Relaxed)
		{
			return offset;
		}

		offset += agitation * this.Parameters.SpawnTimeOffsetInterval;
		return offset;
	}

	function getTimeModifier()
	{
		# The arbitrary coefficients and constants used here are extrapolated from the vanilla codebase.
		return (0.9 + ::Math.minf(2.0, ::World.getTime().Days * 0.014) * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()]);
	}

	function getTooltipEntries( _lairObject )
	{
		local entries = [];
		local push = @(_entry) ::Raids.Standard.push(_entry, entries);

		push(this.createResourcesEntry(_lairObject));
		push(this.createAgitationEntry(_lairObject));
		push(this.createTimerEntry(_lairObject));
		return entries;
	}

	function getTreasureCount( _lairObject )
	{
		return ::Math.ceil(_lairObject.getResources() / 100.0);
	}

	function increaseAgitation( _lairObject )
	{
		::Raids.Standard.incrementFlag("Agitation", 1, _lairObject);
		this.updateProperties(_lairObject, false);
		::Raids.Edicts.refreshEdicts(_lairObject);
		this.Defenders.reinforceDefenders(_lairObject);
		this.repopulateNamedLoot(_lairObject);
	}

	function initialiseLairParameters( _lairObject )
	{
		::Raids.Standard.setFlag("BaseResources", _lairObject.getResources(), _lairObject);
		::Raids.Standard.setFlag("Agitation", this.getField("AgitationDescriptors").Relaxed, _lairObject);
		::Raids.Standard.setFlag("BaseNamedItemChance", this.getNaiveNamedLootChance(_lairObject), _lairObject);
	}

	function isActiveContractLocation( _lairObject )
	{
		local activeContract = ::World.Contracts.getActiveContract();

		if (activeContract == null || !("Destination" in activeContract.m))
		{
			return false;
		}

		local targetLocation = activeContract.m.Destination;

		if (targetLocation == null)
		{
			return false;
		}

		if (!::Raids.Standard.isWeakRef(targetLocation))
		{
			return false;
		}

		if (targetLocation.isNull() || targetLocation.get() != _lairObject)
		{
			return false;
		}

		return true;
	}

	function isFactionViable( _faction )
	{
		local factionType = _faction.getType();
		local viableFactions = this.getField("Factions");

		if (viableFactions.find(factionType) != null)
		{
			return true;
		}

		return false;
	}

	function isLairViableForProcedure( _lairObject, _procedure )
	{
		local agitation = this.getAgitation(_lairObject);

		if (_procedure == ::Raids.Standard.getProcedures().Increment && agitation >= this.getField("AgitationDescriptors").Militant)
		{
			return false;
		}

		return true;
	}

	function isLocationTypePassive( _locationType )
	{
		return _locationType == ::Const.World.LocationType.Passive || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Passive);
	}

	function isLocationViable( _location, _checkContract = true, _checkProximity = false, _checkType = true )
	{
		if (_checkType && !this.isLocationTypeViable(_location.getLocationType()))
		{
			return false;
		}

		if (_checkContract && this.isActiveContractLocation(_location))
		{
			return false;
		}

		if (_checkProximity && !this.isPlayerInProximityTo(_location.getTile()))
		{
			return false;
		}

		return true;
	}

	function isLocationTypeViable( _locationType )
	{
		if (_locationType == ::Const.World.LocationType.Lair)
		{
			return true;
		}

		if (_locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Mobile))
		{
			return true;
		}

		return false;
	}

	function isPlayerInProximityTo( _tile, _threshold = 6 )
	{
		return ::World.State.getPlayer().getTile().getDistanceTo(_tile) <= _threshold;
	}

	function repopulateNamedLoot( _lairObject )
	{
		local iterations = 0;
		local namedLootChance = this.getNamedLootChance(_lairObject) + ::Raids.Edicts.getNamedLootChanceOffset(_lairObject);

		if (namedLootChance > 100)
		{
			iterations += ::Math.floor(namedLootChance / 100);
		}

		if (::Math.rand(1, 100) <= namedLootChance - (iterations * 100))
		{
			iterations += 1;
		}

		if (iterations == 0)
		{
			return;
		}

		local namedLoot = this.createNamedLoot(_lairObject);

		for ( local i = 0; i < iterations; i++ )
		{
			local namedItem = namedLoot[::Math.rand(0, namedLoot.len() - 1)];
			_lairObject.getLoot().add(::new(format("scripts/items/%s", namedItem)));
		}
	}

	function resetAgitation( _lairObject )
	{
		::Raids.Standard.setFlag("Agitation", this.getField("AgitationDescriptors").Relaxed, _lairObject);
		::Raids.Edicts.clearHistory(_lairObject);
	}

	function setAgitation( _lairObject, _procedure )
	{
		if (!this.isLairViableForProcedure(_lairObject, _procedure))
		{
			return;
		}

		local procedures = ::Raids.Standard.getProcedures();

		switch (_procedure)
		{
			case (procedures.Increment): this.increaseAgitation(_lairObject); break;
			case (procedures.Reset): this.resetAgitation(_lairObject); break;
		}

		::Raids.Standard.setFlag("LastAgitationUpdate", ::World.getTime().Days, _lairObject);
	}

	function setResources( _lairObject, _newResources )
	{
		local newResources = ::Math.floor(_newResources);
		_lairObject.setResources(::Math.min(newResources, this.Parameters.ResourcesCeiling));
	}

	function setResourcesByAgitation( _lairObject )
	{
		local newResources = this.getResourcesByAgitation(_lairObject);
		this.setResources(_lairObject, newResources);
	}

	function updateAgitation( _lairObject )
	{
		if (this.getAgitation(_lairObject) == this.getField("AgitationDescriptors").Relaxed)
		{
			return;
		}

		local lastUpdateTimeDays = ::Raids.Standard.getFlag("LastAgitationUpdate", _lairObject);

		if (lastUpdateTimeDays == false)
		{
			return;
		}

		local timeDifference = ::World.getTime().Days - lastUpdateTimeDays;
		local decayInterval = this.getAgitationDecayInterval(_lairObject);

		if (timeDifference < decayInterval)
		{
			return;
		}

		this.setAgitation(_lairObject, ::Raids.Standard.getProcedures().Reset);
		this.depopulateNamedLoot(_lairObject);
		this.updateProperties(_lairObject);
	}

	function updateCombatStatistics( _isParty )
	{
		::Raids.Standard.setFlag("LastFoeWasParty", _isParty, ::World.Statistics);
	}

	function updateProperties( _lairObject, _createDefenders = true )
	{
		this.setResourcesByAgitation(_lairObject);

		if (_createDefenders)
		{
			this.Defenders.createDefenders(_lairObject, true);
		}

		_lairObject.setLootScaleBasedOnResources(_lairObject.getResources());
	}
};