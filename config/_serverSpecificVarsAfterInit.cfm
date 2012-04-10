<cfsetting enablecfoutputonly="true" />

<cfset application.stPlugins["farcryless"] = {
	"stLessLibraries" = {},
	"less" = createObject("component","farcry.plugins.farcryless.packages.custom.less")
} />

<cfsetting enablecfoutputonly="false" />