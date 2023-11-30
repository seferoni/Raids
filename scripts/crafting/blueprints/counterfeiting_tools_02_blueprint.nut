this.counterfeiting_tools_02_blueprint <- ::inherit("scripts/crafting/blueprint",
{
	m = {},
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.counterfeiting_tools_02";
		this.m.PreviewCraftable = ::new("scripts/items/misc/counterfeiting_tools_item");
		this.m.Cost = 250;
		local ingredients = 
		[
			{Script = "scripts/items/misc/writing_instruments_item", Num = 1},
		];
		this.init(ingredients);
	}

	function onCraft( _stash )
	{
		_stash.add(::new("scripts/items/misc/counterfeiting_tools_item"));
	}
});