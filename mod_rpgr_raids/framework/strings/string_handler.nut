::Raids.Strings <-
{
	function compileFragments( _fragmentsArray, _colour )
	{
		local compiledString = "";

		if (_fragmentsArray.len() % 2 != 0)
		{
			_fragmentsArray.push("");
		}

		for( local i = 0; i < _fragmentsArray.len() - 1; i + 2 )
		{
			local concatenatedFragment = format("%s%s", _fragmentsArray[i], ::Raids.Standard.colourWrap(_fragmentsArray[i + 1], ::Raids.Standard.Colour[_colour]));
			compiledString = compiledString == "" ? concatedFragment : format("%s %s", compiledString, concatenatedFragment);
		}

		return compiledString;
	}

	function getFragmentsAsArray( _fragmentBase, _tableKey, _fragmentCount )
	{
		local fragments = [];

		for( local i = 0; i < _fragmentCount; i++ )
		{
			local stringKey = format("%s%s", _fragmentBase, this.mapIntegerToAlphabet(i));
			fragments.push(::Raids.Strings[_tableKey][stringKey]);
		}

		return fragments;
	}

	function getFragmentsAsCompiledString( _fragmentBase, _tableKey, _fragmentCount  = 4, _colour = "Red")
	{
		local fragmentsArray = this.getFragmentsAsArray(_fragmentBase, _tableKey, _fragmentCount);
		return this.compileFragments(fragmentsArray, _colour);
	}

	function mapIntegerToAlphabet( _integer )
	{
		# Counting up from the ASCII equivalent of the letter "A".
		local ASCIIValue = 65 + _integer - 1;
		return ASCIIValue.tochar();
	}

	function loadFiles()
	{
		this.loadFolder("main");
		this.loadFolder("edicts");
	}

	function loadFolder( _path )
	{
		::Raids.Manager.includeFiles(format("mod_rpgr_raids/framework/strings/%s", _path));
	}

	function initialise()
	{
		this.loadFiles();
	}
};