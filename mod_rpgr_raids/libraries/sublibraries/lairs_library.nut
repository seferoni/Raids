local Raids = ::RPGR_Raids;
Raids.Lairs <-
{	// TODO: need some way to revert resources after contracts do their business. hook into tooltip, figure that out (updateResources)
	AgitationDescriptors =
	{
		Relaxed = 1,
		Cautious = 2,
		Vigilant = 3,
		Militant = 4
	},
	Factions =
	[
		"Bandits",
		"Barbarians",
		"Goblins",
		"Orcs",
		"OrientalBandits",
		"Undead",
		"Zombies"
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
		AgitationDecayInterval = 7,
		MaximumLootOffset = 3,
		NamedItemChancePerAgitationTier = 13.33,
		NamedItemRemovalChanceOnSpawn = 90,
		PassiveOfficialDocumentCountCeiling = 2,
		ResourcesCeiling = 700,
		ResourceModifierCeiling = 0.25,
		ResourceModifierLowerBound = 200,
		ResourceModifierUpperBound = 350,
		SpawnTimeOffsetInterval = -50.0,
	},
	Procedures =
	{
		Increment = 1,
		Decrement = 2,
		Reset = 3
	},
	Tooltip =
	{
		Icons =
		{
			Agitated = "ui/icons/miniboss.png",
			Relaxed = "ui/icons/vision.png",
			Resources = "ui/icons/asset_money.png"
		},
		Text =
		{
			id = 20,
			type = "text",
			icon = "",
			text = ""
		}
	}

	function addLoot( _lootTable, _locationObject )
	{
		local count = Raids.Standard.getFlag("Agitation", _locationObject);

		if (!count)
		{
			count = ::Math.rand(1, this.Parameters.PassiveOfficialDocumentCountCeiling);
		}

		for( local i = 0; i < count; i++ )
		{
			_lootTable.push(::new("scripts/items/special/official_document_item"));
		}
	}

	function createAgitationEntry( _lairObject )
	{
		local textColour = Raids.Standard.Colour.Green,
		iconPath = this.Tooltip.Icons.Relaxed,
		agitation = Raids.Standard.getFlag("Agitation", _lairObject);

		# Modify field values when Agitation is above baseline.
		if (agitation != this.AgitationDescriptors.Relaxed)
		{
			textColour = Raids.Standard.Colour.Red;
			iconPath = this.Tooltip.Icons.Agitated;
		}

		# Create Agitation entry.
		local entry = clone this.Tooltip.Text;
		entry.icon = iconPath;
		entry.text = Raids.Standard.colourWrap(format("%s (%i)", Raids.Standard.getDescriptor(agitation, this.AgitationDescriptors), agitation), textColour);
		return entry;
	}

	function createNaiveNamedLoot()
	{
		local namedLoot = [];

		foreach( key in this.NamedItemKeys )
		{
			namedLoot.extend(::Const.Items[key]);
		}

		return namedLoot;
	}

	function createNamedLoot( _lairObject )
	{
		if (::Math.rand(1, 100) > Raids.Standard.getSetting("FactionSpecificNamedLootChance"))
		{
			return this.createNaiveNamedLoot();
		}

		local namedLoot = [],
		keys = this.NamedItemKeys.filter(@(_index, _key) _lairObject.m[format("%sList", _key)] != null);

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

		# Create resources entry.
		local entry = clone this.Tooltip.Text;
		entry.icon <- this.Tooltip.Icons.Resources;
		entry.text <- format("%s resource units", Raids.Standard.colourWrap(resources, Raids.Standard.Colour.Green));
		return entry;
	}

	function createTimerEntry( _lairObject )
	{
		# Prepare auxiliary variables to dictate process flow.
		local agitation = Raids.Standard.getFlag("Agitation", _lairObject),
		lastUpdateDays = Raids.Standard.getFlag("LastAgitationUpdate", _lairObject);

		# Handle cases where the decay timer variable either occupies a value of the wrong type or holds no interest to the user.
		if (!lastUpdateDays || agitation == this.AgitationDescriptors.Relaxed)
		{
			return null;
		}

		# Get time difference.
		local timeDifference = (lastUpdateDays + this.getAgitationDecayInterval(_lairObject)) - ::World.getTime().Days;

		# Create decay timer entry.
		local entry = clone this.Tooltip.Text;
		entry.icon = "ui/icons/action_points.png";
		entry.text = format("%s day(s)", Raids.Standard.colourWrap(timeDifference, Raids.Standard.Colour.Red));
		return entry;
	}

	function depopulateNamedLoot( _lairObject, _chance = null )
	{
		if (_lairObject.getLoot().isEmpty())
		{
			return;
		}

		local namedLootChance = _chance;

		if (_chance == null)
		{
			namedLootChance = this.getNamedLootChance(_lairObject) + Raids.Edicts.getNamedLootChanceOffset(_lairObject, true);
		}

		if (namedLootChance <= 0)
		{
			return;
		}

		local stash = _lairObject.getLoot(),
		loot = stash.getItems().filter(@(_index, _item) _item != null && _item.isItemType(::Const.Items.ItemType.Named));

		foreach( item in loot )
		{
			if (::Math.rand(1, 100) < namedLootChance)
			{
				stash.remove(item);
			}
		}
	}

	function getAgitationDecayInterval( _lairObject )
	{
		local decayInterval = this.Parameters.AgitationDecayInterval + Raids.Edicts.getAgitationDecayOffset(_lairObject);
		return decayInterval;
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
		local Raids = ::RPGR_Raids, entities = ::World.getAllEntitiesAndOneLocationAtPos(_position, 1.0),
		lairs = entities.filter(function( _index, _entity )
		{
			if (!::isKindOf(_entity, "location"))
			{
				return false;
			}
			else if (!Raids.Lairs.isLocationTypeViable(_entity.getLocationType()))
			{
				return false;
			}

			if (Raids.Lairs.isActiveContractLocation(_entity))
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

	function getCandidatesWithin( _tile, _distance = 6 )
	{
		local Lairs = this,
		lairs = ::World.EntityManager.getLocations().filter(function( _index, _location )
		{
			if (!Lairs.isLocationViable(_location))
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

	function getCandidatesByFaction( _faction )
	{
		local lairs = [];

		if (_faction.getSettlements().len() == 0)
		{
			return lairs;
		}

		local Lairs = this;
		lairs.extend(_faction.getSettlements().filter(function( _index, _location )
		{
			if (!Lairs.isLocationViable(_location, false, true))
			{
				return false;
			}

			return true;
		}));

		return lairs;
	}

	function getFactionType( _factionName )
	{
		return ::Const.FactionType[_factionName];
	}

	function getMoneyCount( _lairObject )
	{
		return _lairObject.getResources();
	}

	function getNaiveNamedLootChance( _lairObject )
	{	
		# The arbitrary coefficients and constants used here are taken verbatim from the vanilla codebase.
		local tile = _lairObject.getTile(), settlement = this.getSettlementClosestTo(tile);
		return (_lairObject.getResources() + tile.getDistanceTo(settlement.getTile()) * 4) / 5.0 - 37.0;
	}

	function getNamedLootChance( _lairObject )
	{
		local baseChance = Raids.Standard.getFlag("BaseNamedItemChance", _lairObject),
		agitation = Raids.Standard.getFlag("Agitation", _lairObject);
		return baseChance + ((agitation - 1) * this.Parameters.NamedItemChancePerAgitationTier);
	}

	function getPartyResources( _lairObject )
	{
		# Get current resources value.
		local resources = _lairObject.getResources();

		# Get vanilla time scaling factor.
		local timeModifier = this.getTimeModifier();

		# Get base resources modifier.
		local baseResourceModifier = this.getBaseResourceModifier(Raids.Standard.getFlag("BaseResources", _lairObject));

		# Get user-configured modifier.
		local configurableModifier = Raids.Standard.getPercentageSetting("RoamerResourceModifier");

		# Return product of all factors.
		return baseResourceModifier * configurableModifier * timeModifier * resources;
	}

	function getSettlementClosestTo( _tile )
	{
		local closestSettlement = null,
		closestDistance = 9000;

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
		local offset = 0.0,
		agitation = Raids.Standard.getFlag("Agitation", _lairObject);

		if (agitation == this.AgitationDescriptors.Relaxed)
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
		local entries = [],
		push = @(_entry) entries.push(_entry);

		# Create resources entry.
		push(this.createResourcesEntry(_lairObject));

		# Create Agitation entry.
		push(this.createAgitationEntry(_lairObject));

		# Create Agitation decay timer entry.
		local timerEntry = this.createTimerEntry(_lairObject);

		if (timerEntry != null)
		{
			push(timerEntry);
		}

		return entries;
	}

	function getTreasureCount( _lairObject )
	{
		return ::Math.ceil(_lairObject.getResources() / 100.0);
	}

	function initialiseLairParameters( _lairObject )
	{
		Raids.Standard.setFlag("BaseResources", _lairObject.getResources(), _lairObject);
		Raids.Standard.setFlag("Agitation", this.AgitationDescriptors.Relaxed, _lairObject);
		Raids.Standard.setFlag("BaseNamedItemChance", this.getNaiveNamedLootChance(_lairObject), _lairObject);
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

		if (!Raids.Standard.isWeakRef(targetLocation))
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
		local Lairs = this,
		factionType = _faction.getType(),
		viableFactions = this.Factions.map(@(_factionName) Lairs.getFactionType(_factionName));

		if (viableFactions.find(factionType) != null)
		{
			return true;
		}

		return false;
	}

	function isLairViableForProcedure( _lairObject, _procedure )
	{
		local agitation = Raids.Standard.getFlag("Agitation", _lairObject);

		if (_procedure == this.Procedures.Increment && agitation >= this.AgitationDescriptors.Militant)
		{
			return false;
		}

		if (_procedure == this.Procedures.Decrement && agitation <= this.AgitationDescriptors.Relaxed)
		{
			return false;
		}

		return true;
	}

	function isLocationTypePassive( _locationType )
	{
		return _locationType == ::Const.World.LocationType.Passive || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Passive);
	}

	function isLocationViable( _location, _checkContract = false, _checkProximity = false, _checkType = true )
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
		return _locationType == ::Const.World.LocationType.Lair || _locationType == (::Const.World.LocationType.Lair | ::Const.World.LocationType.Mobile);
	}

	function isPlayerInProximityTo( _tile, _threshold = 6 )
	{
		return ::World.State.getPlayer().getTile().getDistanceTo(_tile) <= _threshold;
	}

	function repopulateNamedLoot( _lairObject )
	{
		local namedLootChance = this.getNamedLootChance(_lairObject) + Raids.Edicts.getNamedLootChanceOffset(_lairObject), iterations = 0;

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

	function setAgitation( _lairObject, _procedure )
	{
		if (!this.isLairViableForProcedure(_lairObject, _procedure))
		{
			return;
		}

		switch (_procedure)
		{
			case (this.Procedures.Increment): Raids.Standard.incrementFlag("Agitation", 1, _lairObject); break;
			case (this.Procedures.Decrement): Raids.Standard.incrementFlag("Agitation", -1, _lairObject); break;
			case (this.Procedures.Reset): Raids.Standard.setFlag("Agitation", this.AgitationDescriptors.Relaxed, _lairObject); break;
		}

		Raids.Standard.setFlag("LastAgitationUpdate", ::World.getTime().Days, _lairObject);
		this.updateProperties(_lairObject, _procedure);
	}

	function setResourcesByAgitation( _lairObject )
	{
		# Get current lair Agitation.
		local agitation = Raids.Standard.getFlag("Agitation", _lairObject);

		# Get resources assigned to the lair upon creation.
		local baseResources = Raids.Standard.getFlag("BaseResources", _lairObject);

		# Create a modifier meant to modulate resource scaling behaviour at both extremes.
		local interpolatedModifier = -0.0006 * baseResources + 0.6;

		# Get configured resources modifier.
		local configurableModifier = Raids.Standard.getPercentageSetting("AgitationResourceModifier");

		# Apply factors as appropriate to produce a new value for resources, scaled by Agitation.
		local newResources = ::Math.floor(baseResources + (interpolatedModifier * (agitation - 1) * configurableModifier * baseResources));

		# Set new resources value.
		_lairObject.setResources(::Math.min(newResources, this.Parameters.ResourcesCeiling));
	}

	function updateCombatStatistics( _isParty )
	{
		Raids.Standard.setFlag("LastFoeWasParty", _isParty, ::World.Statistics);
	}

	function updateAgitation( _lairObject )
	{
		local lastUpdateTimeDays = Raids.Standard.getFlag("LastAgitationUpdate", _lairObject);

		if (!lastUpdateTimeDays)
		{
			return;
		}

		local timeDifference = ::World.getTime().Days - lastUpdateTimeDays,
		decayInterval = this.getAgitationDecayInterval(_lairObject);

		if (timeDifference < decayInterval)
		{
			return;
		}

		local iterations = ::Math.floor(timeDifference / decayInterval);

		if (iterations == 0)
		{
			return;
		}

		for( local i = 0; i < iterations; i++ )
		{
			this.setAgitation(_lairObject, this.Procedures.Decrement);

			if (Raids.Standard.getFlag("Agitation", _lairObject) == this.AgitationDescriptors.Relaxed)
			{
				break;
			}
		}
	}

	function updateProperties( _lairObject, _procedure )
	{
		if (_procedure == this.Procedures.Reset)
		{
			Raids.Edicts.clearEdicts(_lairObject);
			return;
		}

		if (_procedure != this.Procedures.Increment)
		{
			Raids.Edicts.clearHistory(_lairObject);
			this.depopulateNamedLoot(_lairObject);
		}

		this.setResourcesByAgitation(_lairObject);
		_lairObject.createDefenders();
		_lairObject.setLootScaleBasedOnResources(_lairObject.getResources());

		if (_procedure != this.Procedures.Increment)
		{
			return;
		}

		Raids.Edicts.refreshEdicts(_lairObject);
		this.repopulateNamedLoot(_lairObject);
	}
};