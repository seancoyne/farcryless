<cfcomponent output="false" extends="farcry.plugins.testMXUnit.tests.FarcryTestCase">

	<cfimport taglib="/farcry/plugins/farcryless/tags/less" prefix="less" />

	<cffunction name="setup" output="false" returntype="void" access="public">
		<cfscript>
		application.stPlugins["farcryless"] = {
			"stLessLibraries" = {},
			"less" = createObject("component","farcry.plugins.farcryless.packages.custom.less")
		};
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
		assertEquals(fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')),fileRead(expandPath(application.fapi.getwebroot() & '/') & '/less-output-test/' & key & '/test.css'));
		</cfscript>

	</cffunction>

</cfcomponent>