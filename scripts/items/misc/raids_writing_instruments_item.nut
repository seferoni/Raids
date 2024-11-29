this.raids_writing_instruments_item <- ::inherit("scripts/items/raids_item",
{
	m = {},
	function create()
	{
		this.raids_item.create();
		this.assignPropertiesByName("Writing Instruments");
		this.initialiseEdictSelection();
	}

	function assignGenericProperties()
	{
		this.raids_item.assignGenericProperties();
		this.m.Value = 300;
	}

	function assignSoundProperties()
	{
		this.raids_item.assignSoundProperties();
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
			::Raids.Strings.Edicts.WritingInstrumentsInstruction
		);
	}

	function createQueueEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			::Raids.Strings.Edicts.WritingInstrumentsQueueText
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

	function createUsesEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Warning",
			format(::Raids.Strings.Generic.UsesRemaining, ::Raids.Standard.colourWrap(this.getUses(), ::Raids.Standard.Colour.Red))
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
		local edicts = ::Raids.Edicts.getEdictFiles();

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

	function getEdictSelection()
	{
		return ::Raids.Standard.getFlag("EdictSelection", this);
	}

	function getEdictSelectionAsArray()
	{
		local selectionArray = split(this.getEdictSelection(), ",").map(@(sugaredID) strip(sugaredID));
		return selectionArray;
	}

	function getEdictSelectionAsFiles()
	{
		local edictFiles = [];
		local selectionMode = this.getEdictSelectionMode();
		local selectionModes = ::Raids.Edicts.getField("SelectionModes");
		local toFileName = @(_array) _array.map(@(_sugaredID) ::Raids.Edicts.getEdictFileName(_sugaredID)); // TODO: functionalise this, in conjunction with getEdictSelectionAsArray

		switch (selectionMode)
		{
			case selectionModes.Indiscriminate:
			{
				edictFiles.extend(::Raids.Edicts.getEdictFiles());
				break;
			};
			case selectionModes.Agitation:
			{
				edictFiles.push(::Raids.Edicts.getEdictFileName("Agitation"));
				break;
			};
			case selectionModes.Selective:
			{
				edictFiles.extend(toFileName(this.getEdictSelectionAsArray()));
				break;
			};
			case selectionModes.Inverted:
			{
				local naiveEdicts = ::Raids.Edicts.getEdictFiles();
				::Raids.Standard.removeFromArray(toFileName(this.getEdictSelectionAsArray()), naiveEdicts);
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
			local colourValue = ::Raids.Standard.Colour[selectionMode == selectionModes.Selective ? "Green" : "Red"];
			local selection = ::Raids.Standard.colourWrap(this.getEdictSelection(), colourValue);
			return format("%s: %s", ::Raids.Standard.getKey(selectionMode, selectionModes), selection);
		}

		return ::Raids.Standard.colourWrap(::Raids.Standard.getKey(selectionMode, selectionModes), ::Raids.Standard.Colour.Red);
	}

	function getField( _fieldName )
	{
		return ::Raids.Edicts.getField(_fieldName);
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
		local tooltipArray = this.raids_item.getTooltip();
		local push = @(_entry) ::Raids.Standard.push(_entry, tooltipArray);

		push(this.createUsesEntry());

		if (this.isFirstInQueue())
		{
			push(this.createQueueEntry());
		}

		push(this.createSelectionModeEntry());
		push(this.createInstructionEntry());
		return tooltipArray;
	}

	function getUses()
	{
		return ::Raids.Standard.getFlag("Uses", this);
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

		::Raids.Standard.setFlag("EdictSelection", selection, this);
		::Raids.Standard.setFlag("EdictSelectionMode", selectionModes.Selective, this);
	}

	function onAddedToStash( _stashID )
	{
		this.raids_item.onAddedToStash(_stashID);

		if (_stashID != "player")
		{
			return;
		}

		this.setShowingQueueState();
		::Raids.Standard.setFlag("EdictSelectionMode", ::Raids.Edicts.getField("Indiscriminate"), this);
	}

	function onRemovedFromStash( _stashID )
	{
		this.raids_item.onRemovedFromStash(_stashID);

		if (_stashID != "player")
		{
			return;
		}

		this.setShowingQueueState(false);
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

	function setShowingQueueState( _boolean = true )
	{
		::Raids.Standard.setFlag("ShowQueueState", _boolean, this);
	}
});