this.raids_writing_instruments_item <- ::inherit("scripts/items/raids_stackable_item",
{
	m = {},
	function create()
	{
		this.raids_stackable_item.create();
		this.assignPropertiesByName("Writing Instruments");
		this.initialiseEdictSelection();
	}

	function assignGenericProperties()
	{
		this.raids_stackable_item.assignGenericProperties();
		this.m.Value = 300;
	}

	function assignPropertiesByName( _properName )
	{
		this.raids_stackable_item.assignPropertiesByName(_properName);
		this.setIconByName(_properName);
	}

	function assignSoundProperties()
	{
		this.raids_stackable_item.assignSoundProperties();
		this.m.InventorySound = "sounds/move_pot_clay_01.wav";
		this.m.UseSound =
		[
			"sounds/raids.paper_01.wav",
			"sounds/raids.paper_02.wav",
			"sounds/raids.paper_03.wav"
		];
	}

	function createInstructionEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			null,
			::Raids.Strings.Edicts.Common.WritingInstrumentsInstruction
		);
	}

	function createQueueEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			::Raids.Strings.Edicts.Common.WritingInstrumentsQueueText
		);
	}

	function createSelectionModeEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Special",
			this.getEdictSelectionText()
		);
	}

	function createStackEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			format(::Raids.Strings.Generic.UsesRemaining, ::Raids.Standard.colourWrap(this.getCurrentStacks(), ::Raids.Standard.Colour.Red))
		);
	}

	function cycleSelectionMode()
	{
		local selectionMode = this.getEdictSelectionMode();
		local selectionModes = ::Raids.Edicts.getField("SelectionModes");

		if (selectionMode == selectionModes.Inverted)
		{
			selectionMode = selectionModes.Indiscriminate;
		}
		else
		{
			selectionMode += 1;
		}

		this.setEdictSelectionMode(selectionMode);
	}

	function getEdictCandidates()
	{
		local selectedEdicts = [];
		local edicts = ::Raids.Edicts.getAllEdictsAsFiles();

		while (selectedEdicts.len() < ::Raids.Edicts.Parameters.WritingInstrumentsSelectionSize)
		{
			local candidate = ::Raids.Edicts.getSugaredID(edicts[::Math.rand(0, edicts.len() - 1)], true);

			if (selectedEdicts.find(candidate) != null)
			{
				continue;
			}

			if (::Raids.Edicts.getField("Excluded").find(candidate) != null)
			{
				continue;
			}

			selectedEdicts.push(candidate);
		}

		return selectedEdicts;
	}

	function getNaiveEdictSelection()
	{
		return ::Raids.Standard.getFlag("EdictSelection", this);
	}

	function getNaiveEdictSelectionAsFiles()
	{
		local selectionArray = split(this.getNaiveEdictSelection(), ",").map(@(sugaredID) strip(sugaredID));
		return selectionArray.map(@(_sugaredID) ::Raids.Edicts.getEdictFilePathBySugaredID(_sugaredID));
	}

	function getEdictSelectionAsFiles()
	{
		local edictFiles = [];
		local selectionMode = this.getEdictSelectionMode();
		local selectionModes = ::Raids.Edicts.getField("SelectionModes");

		switch (selectionMode)
		{
			case selectionModes.Indiscriminate:
			{
				edictFiles.extend(::Raids.Edicts.getAllEdictsAsFiles());
				break;
			};
			case selectionModes.Agitation:
			{
				edictFiles.push(::Raids.Edicts.getEdictFilePathBySugaredID("Agitation"));
				break;
			};
			case selectionModes.Selective:
			{
				edictFiles.extend(this.getNaiveEdictSelectionAsFiles());
				break;
			};
			case selectionModes.Inverted:
			{
				local naiveEdicts = ::Raids.Edicts.getAllEdictsAsFiles();
				::Raids.Standard.removeFromArray(this.getNaiveEdictSelectionAsFiles(), naiveEdicts);
				edictFiles.extend(naiveEdicts);
			};
		}

		return edictFiles;
	}

	function getEdictSelectionMode()
	{
		return ::Raids.Standard.getFlag("EdictSelectionMode", this);
	}

	function getEdictSelectionText()
	{
		local selectionMode = this.getEdictSelectionMode();
		local selectionModes = ::Raids.Edicts.getField("SelectionModes");

		if (selectionMode != selectionModes.Indiscriminate && selectionMode != selectionModes.Agitation)
		{
			local colour = ::Raids.Standard.Colour[selectionMode == selectionModes.Selective ? "Green" : "Red"];
			local selection = ::Raids.Standard.colourWrap(this.getNaiveEdictSelection(), colour);
			return format("%s: %s", ::Raids.Standard.getKey(selectionMode, selectionModes), selection);
		}

		return ::Raids.Standard.colourWrap(::Raids.Standard.getKey(selectionMode, selectionModes), ::Raids.Standard.Colour.Red);
	}

	function isFirstInQueue()
	{
		if (!this.isShowingQueueState())
		{
			return false;
		}

		local candidates = ::Raids.Edicts.getAllWritingInstrumentsInstancesInStash();

		# Handle case where the current object is the only valid instance.
		if (candidates.len() == 1)
		{
			return false;
		}

		local currentPosition = candidates.find(this);
		local selectionMode = this.getEdictSelectionMode();
		local selectionModes = ::Raids.Edicts.getField("SelectionModes");

		# Handle case where the current object is unequivocally not first in queue.
		if (selectionMode == selectionModes.Indiscriminate && currentPosition != 0)
		{
			return false;
		}

		local originIndex = 0;
		local thresholdIndex = currentPosition;

		if (selectionMode == selectionModes.Indiscriminate)
		{
			originIndex = currentPosition;
			thresholdIndex = candidates.len();
		}

		for( local i = originIndex; i < thresholdIndex; i++ )
		{
			if (candidates[i].getEdictSelectionMode() != selectionModes.Indiscriminate)
			{
				return false;
			}
		}

		return true;
	}

	function getTooltip()
	{
		local tooltipArray = this.raids_stackable_item.getTooltip();
		local push = @(_entry) ::Raids.Standard.push(_entry, tooltipArray);

		if (this.isFirstInQueue())
		{
			push(this.createQueueEntry());
		}

		push(this.createSelectionModeEntry());
		push(this.createInstructionEntry());
		return tooltipArray;
	}

	function initialiseEdictSelection()
	{
		local selection = "";
		local edictCandidates = this.getEdictCandidates();
		local selectionModes = ::Raids.Edicts.getField("SelectionModes");

		foreach( edictName in edictCandidates )
		{
			selection = ::Raids.Standard.appendToStringList(selection, edictName);
		}

		this.setEdictSelection(selection);
		this.setEdictSelectionMode(selectionModes.Selective);
	}

	function onAddedToStash( _stashID )
	{
		if (_stashID != "player")
		{
			return;
		}

		this.setShowQueueState();
		::Raids.Standard.setFlag("EdictSelectionMode", ::Raids.Edicts.getField("Indiscriminate"), this);
	}

	function onRemovedFromStash( _stashID )
	{
		if (_stashID != "player")
		{
			return;
		}

		this.setShowQueueState(false);
	}

	function onStackUpdate()
	{
		return;
	}

	function onUse( _actor, _item = null )
	{
		this.cycleSelectionMode();
		this.playUseSound();
		::Tooltip.reload();
		return false;
	}

	function setEdictSelection( _selection )
	{
		::Raids.Standard.setFlag("EdictSelection", _selection, this);
	}

	function setEdictSelectionMode( _selectionMode )
	{
		::Raids.Standard.setFlag("EdictSelectionMode", _selectionMode, this);
	}

	function isShowingQueueState()
	{
		return ::Raids.Standard.getFlag("ShowQueueState", this);
	}

	function setShowQueueState( _boolean = true )
	{
		::Raids.Standard.setFlag("ShowQueueState", _boolean, this);
	}
});