local Raids = ::RPGR_Raids;
::mods_hookExactClass("entity/world/settlements/buildings/marketplace_building", function( _object )
{   
    Raids.Standard.wrap(_object, "fillStash", function( _list, _stash, _priceMult, _allowDamagedEquipment = false )
    {
        this.building.fillStash(_list, _stash, _priceMult, _allowDamagedEquipment);

        if (::Math.rand(1, 100) > Raids.Edicts.Internal.WritingInstrumentsChance)
        {
            return;
        }

        if (this.m.Settlement.getSize() < 3)
		{
            return;
        }

        this.m.Stash.add(::new("scripts/items/misc/writing_instruments_item"));
        this.m.Stash.sort();
    });
});