::mods_hookExactClass("entity/world/settlements/situations/raided_situation", function ( object )
{
    local parentName = object.SuperName;

	local oA_nullCheck = "onAdded" in object ? object.onAdded : null;
	object.onAdded = function( _settlement )
	{
		local vanilla_onAdded = oA_nullCheck == null ? this[parentName].onAdded(_settlement) : oA_nullCheck(_settlement);
		local activeContract = ::World.Contracts.getActiveContract();
		local severity = (activeContract != null && activeContract.isTileUsed(_settlement.getTile())) ? ::RPGR_Raids.SeverityDescriptors.Unscathed : ::RPGR_Raids.getSeverityScore(_settlement);

		if (severity < ::RPGR_Raids.SeverityDescriptors.Sacked)
		{
			return vanilla_onAdded;
		}

		_settlement.m.isActive = false;
		this.setValidForDays(::RPGR_Raids.Mod.ModSettings.getSetting("RaidedDuration").getValue());
		::RPGR_Raids.setRaidedSettlementVisuals(_settlement, true);
		return vanilla_onAdded;
	}

	local oR_nullCheck = "onRemoved" in object ? object.onRemoved : null;
	object.onRemoved <- function( _settlement )
	{
		local vanilla_onRemoved = oR_nullCheck == null ? this[parentName].onRemoved(_settlement) : oR_nullCheck(_settlement);
		_settlement.m.isActive = true;
		_settlement.getFlags().set("RaidSeverity", false);
		::RPGR_Raids.setRaidedSettlementVisuals(_settlement, false);
		return vanilla_onRemoved;
	}
});