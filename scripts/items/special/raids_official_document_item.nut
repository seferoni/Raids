this.raids_official_document_item <- ::inherit("scripts/items/raids_stackable_item",
{
	m = {},
	function create()
	{
		this.raids_stackable_item.create();
		this.assignPropertiesByName("Official Document");
	}

	function addEdictToStash()
	{
		local writingInstruments = ::Raids.Edicts.getFirstQueuedWritingInstrumentsInstance();
		local newEdict = ::Raids.Edicts.createEdict(writingInstruments);
		::World.Assets.getStash().add(newEdict);

		if (writingInstruments != null)
		{
			::Raids.Edicts.updateWritingInstruments(writingInstruments);
		}
	}

	function assignGenericProperties()
	{
		this.raids_stackable_item.assignGenericProperties();
		this.setNativeIcon("special/raids_official_document_item");
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
	{
		this.playUseSound();
		this.addEdictToStash();
		this.setStacks(::Raids.Standard.getProcedures().Decrement);
		return this.isFlaggedForRemoval();
	}
});