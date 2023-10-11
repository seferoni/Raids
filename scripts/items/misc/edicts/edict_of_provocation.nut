local Raids = ::RPGR_Raids;
this.edict_of_provocation <- ::inherit("scripts/items/item/misc/edict",
{
    m = {},
	function create()
	{
		this.edict.create();
        this.m.ID = "misc.edict_of_provocation";
		this.m.Name = "Edict of Provocation";
		this.m.Description = "A thoroughly illegal facsimile of official correspondence. This document appraises the martial capabilities of the enemies of the realm, and subsequently finds them lacking.";
		this.m.Icon = "consumables/.png";
		this.m.Value = 50;
        this.m.EffectText = "Will issue a challenge to all lairs in proximity. The next roaming party to be produced from these lairs will be strongly reinforced. Destroying this party will greatly agitate nearby lairs.";
	}
});