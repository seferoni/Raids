this.counterfeiting_tools_01_blueprint <- ::inherit("scripts/crafting/blueprint",
{
	m = {},
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.counterfeiting_tools_01";
		this.m.PreviewCraftable = ::new("scripts/items/special/counterfeiting_tools_item");
		this.m.Cost = 100; // FIXME: prices need adjustment balancing
		local ingredients =
        [
			{Script = "scripts/items/misc/spider_silk_item", Num = 1},
			{Script = "scripts/items/misc/poison_gland_item", Num = 1}
		];
		this.init(ingredients);
	}

	function onCraft( _stash )
	{
		_stash.add(::new("scripts/items/special/counterfeiting_tools_item"));
	}
});