::Raids.Patcher.hook("scripts/entity/world/settlements/buildings/marketplace_building", function( p )
{
	::Raids.Patcher.wrap(p, "fillStash", function( _list, _stash, _priceMult, _allowDamagedEquipment = false )
	{
		if (this.getSettlement().getSize() < 3)
		{
			return;
		}

		if (::Math.rand(1, 100) > ::Raids.Edicts.Internal.WritingInstrumentsChance)
		{
			return;
		}

		this.m.Stash.add(::new("scripts/items/misc/writing_instruments_item"));
		this.m.Stash.sort();
	});
});