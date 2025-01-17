this.raids_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.assignGenericProperties();
		this.assignSoundProperties();
		this.createFlags();
		this.assignSpecialProperties();
	}

	function assignGenericProperties()
	{
		this.m.IsUsable = true;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
	}

	function assignSoundProperties()
	{
		this.m.UseSound <- "";
		this.m.InventorySound <- "";
		this.m.WarningSound <- "sounds/move_pot_clay_01.wav";
	}

	function assignSpecialProperties()
	{
		this.m.DescriptionPrefix <- "";
		this.m.GFXPathPrefix <- "consumables/";
		this.m.Warnings <- {};
	}

	function createFlags()
	{
		this.m.Flags <- ::new("scripts/tools/tag_collection");
		this.getFlags <- function()
		{
			return this.m.Flags;
		}
	}

	function createWarningEntries()
	{
		local entries = [];
		local warning = this.getActiveWarnings();

		if (warning.len() == 0)
		{
			return null;
		}

		foreach( warning in warnings )
		{
			::Raids.Standard.constructEntry
			(
				"Warning",
				::Raids.Standard.colourWrap(::Raids.Strings.Warnings[warning], ::Raids.Standard.Colour.Red),
				entries
			);
		}

		this.resetWarnings();
		return entries;
	}

	function formatName( _properName, _replacementSubstring = "" )
	{
		return ::Raids.Standard.replaceSubstring(" ", _replacementSubstring, _properName);
	}

	function getActiveWarnings()
	{
		local warnings = [];

		foreach( warning, warningState in this.m.Warnings )
		{
			if (warningState)
			{
				warnings.push(warning);
			}
		}

		return warnings;
	}

	function getTooltip()
	{
		local tooltipArray = [];
		local push = @(_entry) ::Raids.Standard.push(_entry, tooltipArray);

		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		push({id = 66, type = "text", text = this.getValueString()});
		push({id = 3, type = "image", image = this.getIcon()});
		return tooltipArray;
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.Flags.onDeserialize(_in);
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		this.m.Flags.onSerialize(_out);
	}

	function playSound( _soundSource )
	{
		if (typeof _soundSource != "array")
		{
			::Sound.play(_soundSource, ::Const.Sound.Volume.Inventory);
			return;
		}

		::Sound.play(_soundSource[::Math.rand(0, _soundSource.len() - 1)], ::Const.Sound.Volume.Inventory);
	}

	function playInventorySound( _eventType )
	{
		this.playSound(this.m.InventorySound);
	}

	function playUseSound()
	{
		this.playSound(this.m.UseSound);
	}

	function playWarningSound()
	{
		this.playSound(this.m.WarningSound);
	}

	function setIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("misc.raids_%s_item", formattedName.tolower());
	}

	function setIconByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.Icon = format("%s/raids_%s_item.png", this.m.GFXPathPrefix, formattedName.tolower());
	}

	function setWarning( _warning, _boolean = true )
	{
		this.m.Warnings[_warning] = _boolean;
		::Tooltip.reload();
	}
});