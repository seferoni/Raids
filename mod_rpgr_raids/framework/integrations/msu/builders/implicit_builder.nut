::Raids.Integrations.MSU.Builders.Implicit <-
{
	function addSettingImplicitly( _settingID, _settingValues, _pageID )
	{
		local settingElement = null;

		switch (typeof _settingValues.Default)
		{
			case ("bool"): settingElement = this.createBooleanSetting(_settingID, _settingValues); break;
			case ("float"):
			case ("integer"): settingElement = this.createNumericalSetting(_settingID, _settingValues); break;
		}

		if (settingElement == null)
		{
			::Raids.Standard.log(format("Passed element with ID %s had an unexpected default value type, skipping for implicit construction.", _settingID), true);
			return;
		}

		::Raids.Integrations.MSU.buildDescription(settingElement);
		::Raids.Integrations.MSU.appendElementToPage(settingElement, _pageID);
	}

	function build()
	{
		this.buildPages();

		foreach( category, settingGroup in ::Raids.Database.Parameters )
		{
			local pageID = format("Page%s", category);
			this.buildImplicitly(pageID, settingGroup);
		}
	}

	function buildPages()
	{
		local pageCategories = ::Raids.Database.getSettingCategories();

		foreach( category in pageCategories )
		{
			local pageID = format("Page%s", category);
			local pageName = ::Raids.Integrations.MSU.getElementName(pageID);
			::Raids.Integrations.MSU.addPage(pageID, pagename);
		}
	}

	function buildImplicitly( _pageID, _settingGroup )
	{
		foreach( settingID, settingValues in _settingGroup )
		{
			this.addSettingImplicitly(settingID, settingValues, _pageID);
		}
	}

	function createBooleanSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.BooleanSetting(_settingID, _settingValues.Default, ::Raids.Integrations.MSU.getElementName(_settingID));
	}

	function createNumericalSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.RangeSetting(_settingID, _settingValues.Default, _settingValues.Range[0], _settingValues.Range[1], _settingValues.Interval, ::Raids.Integrations.MSU.getElementName(_settingID));
	}
};