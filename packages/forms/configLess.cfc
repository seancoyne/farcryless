<cfcomponent output="false" extends="farcry.core.packages.forms.forms" key="farcryless" displayname="LESS Compiler" hint="Configure the LESS compiler">

	<cfproperty ftSeq="110" ftFieldset="LESS" ftLabel="Output Directory" name="outputDir" type="nstring" ftType="string" default="/css" ftDefault="/css" ftHint="Where should compiled LESS files be stored? Provide the path relative to the webroot." />
	<cfproperty ftSeq="120" ftFieldset="LESS" ftLabel="Always Recompile?" name="bAlwaysRecompile" type="boolean" ftType="boolean" default="0" ftDefault="0" ftHint="Always recompile the LESS files on each request?  Not recommended for production use, but helpful during development." />

</cfcomponent>