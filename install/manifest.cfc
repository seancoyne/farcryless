<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">
	<cfset this.name = "FarCry LESS" />
	<cfset this.description = "A LESS compiler for FarCry" />
	<cfset this.lRequiredPlugins = "" />
	<cfset this.version = "1.0.0" />
	<cfset addSupportedCore(majorVersion="6", minorVersion="1", patchVersion="4") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="2", patchVersion="0") />
</cfcomponent>