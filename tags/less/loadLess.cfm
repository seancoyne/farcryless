<cfsetting enablecfoutputonly="yes" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not thisTag.HasEndTag>
	<cfabort showerror="less:loadLess requires an end tag." />
</cfif>

<cfif thistag.executionMode eq "Start">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "End">

	<cfparam name="attributes.id" default=""><!--- The id of the library that has been registered with the application --->

	<cfparam name="attributes.baseHREF" default=""><!--- The base directory the Less files, should be the full, absolute path without the trailing slash --->
	<cfparam name="attributes.lFiles" default=""><!--- The files to include in that baseHREF --->
	<cfparam name="attributes.prepend" default=""><!--- Less code that will be compiled separately and the compiled css will be passed to the loadCSS tag's prepend attribute --->
	<cfparam name="attributes.append" default=""><!--- Less code that will be compiled separately and the compiled css will be passed to the loadCSS tag's append attribute --->

	<cfparam name="attributes.bCombine" default="true"><!--- Should the compiled CSS files be combined into a single cached CSS file, this is passed along to the loadCSS tag --->
	<cfparam name="attributes.media" default=""><!--- the media type to use in the style tag, this is passed along to the loadCSS tag --->
	<cfparam name="attributes.condition" default=""><!--- the condition to wrap around the style tag, this is passed along to the loadCSS tag --->

	<cfparam name="attributes.outputdir" default="" /><!--- the output dir to store compiled css files.  specify a path relative to the webroot  by default the directory specified in the LESS config will be used, this can be used to override that value --->

	<cfif len(trim(thisTag.generatedContent))>
		<cfset attributes.append = "#attributes.append##thisTag.generatedContent#" />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	<cfset stLess = duplicate(attributes) />

	<cfset less = application.stPlugins["farcryless"].less />

	<cfif len(stLess.id) and less.isRegistered(stLess.id)>
		<cfset stLess = less.getLibrary(stLess.id) />
	<cfelseif len(stLess.id)>
		<cfset less.registerLess(argumentCollection = stLess) />
	<cfelse>
		<cfset stLess.id = hash(stLess.baseHREF & stLess.lFiles & attributes.prepend & attributes.append,'md5','utf-8') />
		<cfset less.registerLess(argumentCollection = stLess) />
	</cfif>

	<cfset stLess.bCombine = attributes.bCombine />
	<cfset stLess.media = attributes.media />
	<cfset stLess.condition = attributes.condition />

	<cfif not len(trim(attributes.outputdir))>
		<cfset attributes.outputDir = application.fapi.getConfig(key = 'farcryless', name = 'outputDir', default = '/less-output') />
	</cfif>

	<!--- check if less has already been compiled, if so, just use the existing compiled version --->
	<cfif application.fapi.getConfig(key = 'farcryless', name = 'bAlwaysRecompile', default = false) or not less.isLibraryCompiled(id = stLess.id, outputDir = attributes.outputDir)>
		<cfset stCss = less.compileLessLibrary(id = stLess.id, outputDir = attributes.outputDir) />
	<cfelse>
		<cfset stCss = less.getCompiledLibrary(id = stLess.id, outputDir = attributes.outputDir) />
	</cfif>

	<skin:loadCss attributeCollection="#stCss#" />

</cfif>

<cfsetting enablecfoutputonly="no" />