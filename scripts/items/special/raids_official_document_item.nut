this.raids_official_document_item <- ::inherit("scripts/items/raids_stackable_item",
{
	m = {},
	function create()
	{
		this.raids_stackable_item.create();
		this.assignPropertiesByName("Official Document");
	}

	function assignGenericProperties()
	{
		this.raids_stackable_item.assignGenericProperties();
		this.setNativeIcon("special/raids_official_document_item.png");
		this.setNativeValue(150);
	}

	function assignSoundProperties()
	{
		this.raids_stackable_item.assignSoundProperties();
		this.m.UseSound = "sounds/cloth_01.wav";
		this.m.InventorySound = "sounds/cloth_01.wav";
	}

	function createEffectEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			"Special",
			::Raids.Strings.Edicts.OfficialDocumentEffect
		);
	}

	function createInstructionEntry()
	{
		return ::Raids.Standard.constructEntry
		(
			null,
			::Raids.Strings.Edicts.OfficialDocumentInstruction
		);
	}

	function getTooltip()
	{
		local tooltipArray = this.raids_stackable_item.getTooltip();
		local push = @(_entry) ::Raids.Standard.push(_entry, tooltipArray);

		push(this.createEffectEntry());
		push(this.createInstructionEntry());
		return tooltipArray;
	}

	function onUse( _actor, _item = null )
	{	// TODO: anti-symmetry between this and edict item onUse implementation. not acceptable.
		local writingInstruments = ::Raids.Edicts.getFirstQueuedWritingInstrumentsInstance();
		::World.Assets.getStash().add(::Raids.Edicts.createEdict(writingInstruments));
		this.playUseSound();

		if (writingInstruments == null)
		{	// TODO: this is rather ugly. generally dissatisfied with onUse implementations
			return this.isFlaggedForRemoval();
		}

		# Terminate execution if the only Writing Instruments instance present is set to indiscriminate Edict selection.
		if (writingInstruments.getEdictSelectionMode() == ::Raids.Edicts.getField("SelectionModes").Indiscriminate)
		{
			return this.isFlaggedForRemoval();
		}

		writingInstruments.decrementUses();
		this.setStacks(this.getProcedures().Decrement);
		return this.isFlaggedForRemoval();
	}
});