<cfcomponent output="false" extends="farcry.plugins.testMXUnit.tests.FarcryTestCase">

	<cfimport taglib="/farcry/plugins/farcryless/tags/less" prefix="less" />

	<cffunction name="setup" output="false" returntype="void" access="public">
		<cfscript>
		application.stPlugins["farcryless"] = {
			"stLessLibraries" = {},
			"less" = createObject("component","farcry.plugins.farcryless.packages.custom.less")
		};
		variables.testOutputDir = expandPath(application.fapi.getwebroot() & '/') & 'less-output-test';
		if (directoryExists(variables.testOutputDir)) {
			directoryDelete(variables.testOutputDir, true);
		}
		super.setup();
		</cfscript>
	</cffunction>

	<cffunction name="testRegisterLess" output="false" returntype="void" access="public">

		<cfscript>
		// assert that the key does not exist in the struct
		assertFalse(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));
		</cfscript>

		<!--- register a library --->
		<less:registerLess id="test" />

		<cfscript>
		// assert that the key exists in the struct
		assertTrue(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));
		</cfscript>

	</cffunction>

	<cffunction name="testRegisterLessGeneratedContent" output="false" returntype="void" access="public">

		<cfscript>
		// assert that the key does not exist in the struct
		assertFalse(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));
		</cfscript>

		<!--- register a library w/ generated content --->
		<less:registerLess id="test"><cfoutput>div { width: 1 + 1 }</cfoutput></less:registerLess>

		<cfscript>
		// assert that the key exists in the struct
		assertTrue(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));

		// assert that the "append" value is correct
		assertEquals("div { width: 1 + 1 }", application.stPlugins["farcryless"].stLessLibraries["test"].append);
		</cfscript>

	</cffunction>

	<cffunction name="testLoadLessRegistersNewLibrary" output="false" returntype="void" access="public">

		<cfscript>
		// assert that the key does not exist in the struct
		assertFalse(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));
		</cfscript>

		<!--- register a library --->
		<less:loadLess id="test" baseHref="#expandPath('/farcry/plugins/farcryless/tests/data')#" lFiles="test.less" outputDir="/less-output-test" />

		<cfscript>
		// assert that the key exists in the struct
		assertTrue(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));
		</cfscript>

	</cffunction>

	<cffunction name="testLoadLessRegistersAndCompilesUnnamedLibrary" output="false" returntype="void" access="public">

		<cfscript>
		// assert there are no keys in the struct
		assertEquals(0,structCount(application.stPlugins["farcryless"].stLessLibraries));
		</cfscript>

		<!--- register a library --->
		<less:loadLess baseHref="#expandPath('/farcry/plugins/farcryless/tests/data')#" lFiles="test.less" outputDir="/less-output-test"><cfoutput>div { width: 1 + 1 }</cfoutput></less:loadLess>

		<cfscript>
		// assert that the key exists in the struct
		assertEquals(1,structCount(application.stPlugins["farcryless"].stLessLibraries));

		// assert that the "compiled" key exists in the struct
		var key = structKeyList(application.stPlugins["farcryless"].stLessLibraries);
		assertTrue(structKeyExists(application.stPlugins["farcryless"].stLessLibraries[key], 'compiled'));
		assertEquals(fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')),application.stPlugins["farcryless"].stLessLibraries[key].compiled.append);
		assertEquals(fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')),fileRead(variables.testOutputDir & '/' & key & '/test.css'));
		</cfscript>

	</cffunction>

	<cffunction name="testHashCheck" output="false" returntype="void" access="public">

		<!--- run the tag, w/o registering, verify exists, note hash --->
		<less:loadLess id="test" baseHref="#expandPath('/farcry/plugins/farcryless/tests/data')#" lFiles="test.less" outputDir="/less-output-test" />
		<cfset var originalHash = application.stPlugins["farcryless"].stLessLibraries["test"].hash />

		<!--- run again, keep the same definition, note hash --->
		<less:loadLess id="test" baseHref="#expandPath('/farcry/plugins/farcryless/tests/data')#" lFiles="test.less" outputDir="/less-output-test" />
		<cfset var anotherHash = application.stPlugins["farcryless"].stLessLibraries["test"].hash />

		<!--- compare hashes, if different, fail --->
		<cfset assertEquals(originalHash, anotherHash) />

		<!--- run again, change the definition but keep the same ID, note hash --->
		<less:loadLess id="test" baseHref="#expandPath('/farcry/plugins/farcryless/tests/data/alt')#" lFiles="test.less" outputDir="/less-output-test" />
		<cfset var newHash = application.stPlugins["farcryless"].stLessLibraries["test"].hash />

		<!--- compare hashes, if they are the same, fail --->
		<cfset assertNotEquals(originalHash, newHash) />

	</cffunction>

</cfcomponent>