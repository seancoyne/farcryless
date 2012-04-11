component extends="farcry.plugins.testMXUnit.tests.FarcryTestCase" {

	public function setup() {
		variables.less = createObject("component","farcry.plugins.farcryless.packages.custom.less");
		structDelete(application.stPlugins["farcryless"],"javaloader");
		structDelete(application.stPlugins["farcryless"],"lessengine");
		application.stPlugins["farcryless"].stLessLibraries = {};
		super.setup();
	}

	public void function testCompileLessLibrary() {

		/*
			obviously in a real use case you wouldn't provide the exact same less
			code for the lFiles and the append and prepend attributes, but this way
			its easy to test against known responses.
		*/

		application.stPlugins['farcryless'].stLessLibraries["test"] = {
			id = "test",
			baseHREF = expandPath('/farcry/plugins/farcryless/tests/data'),
			lFiles = "test.less",
			media = "all",
			append = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/test.less')),
			prepend = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/test.less')),
			condition = "",
			bCombine = true
		};

		var outputDir = expandPath(application.fapi.getwebroot() & '/') & 'less-output-test/test';

		if (directoryExists(outputDir)) {
			directoryDelete(outputDir,true);
		}

		var result = variables.less.compileLessLibrary(id = "test", outputDir = "/less-output-test");

		assertTrue(directoryExists(outputDir), "Output directory (#outputDir#) did not exist");
		assertTrue(fileExists(outputDir & '/test.css'), "Output file did not exist!");
		assertEquals(fileRead(outputDir & '/test.css'), fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')));
		assertEquals(result.append, fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')));
		assertEquals(result.prepend, fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')));

	}

	public void function testGetCompiledLibrary() {
		// create a fake compiled library
		application.stPlugins["farcryless"].stLessLibraries["test"] = {
			id = "test",
			baseHREF = expandPath('/farcry/plugins/farcryless/tests/data'),
			lFiles = "test.less",
			media = "all",
			append = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/test.less')),
			prepend = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/test.less')),
			condition = "",
			bCombine = true,
			compiled = {
				append = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')),
				prepend = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css'))
			}
		};
		fileWrite(expandPath(application.fapi.getwebroot() & "/") & "/less-output-test/test/test.css", fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')));
		var actual = variables.less.getCompiledLibrary("test",'/less-output-test');
		var expected = {
			id = "test",
			baseHREF = application.fapi.getwebroot() & "/less-output-test/test",
			lFiles = "test.css",
			media = "all",
			condition = "",
			prepend = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')),
			append = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css')),
			bCombine = true,
			lCombineIDs = "",
			hostname = ""
		};
		assertStructEquals(expected, actual);
	}

	public void function testRegisterLess() {
		// assert that the key does not exist in the struct
		assertFalse(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"), "Library already existed, test aborted");
		// register a less library
		variables.less.registerLess(id = "test", baseHref="/my/fake/path", lFiles = "file.less", append = "", prepend = "");
		// assert that the key exists in the struct
		assertTrue(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"), "Library did not exist");

		// assert the hash exists and is correct
		assertTrue(structKeyExists(application.stPlugins["farcryless"].stLessLibraries["test"],"hash"),"Hash key did not exist in library");
		var expectedhash = hash("/my/fake/pathfile.less","md5","utf-8");
		var actualhash = application.stPlugins["farcryless"].stLessLibraries["test"].hash;
		assertEquals(expectedhash, actualhash,"Hashes did not match");
	}

	public void function testUnregisterLess() {

		application.stPlugins.farcryless.stLessLibraries["test"] = { id = "test" };

		// assert that the key does exist in the struct
		assertTrue(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));

		// unregister
		variables.less.unregisterLess(id = "test");

		// assert that the key does not exist in the struct
		assertFalse(structKeyExists(application.stPlugins["farcryless"].stLessLibraries, "test"));
	}

	public void function testCompileLess() {
		var less = "div { width: 1 + 1 }";
		var expected = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css'));
		makePublic(variables.less,"compileLess");
		var actual = variables.less.compileLess(less);
		assertEquals(expected, actual);
	}

	public void function testCompileLessCompressed() {
		var less = "div { width: 1 + 1 }";
		var expected = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.min.css'));
		makePublic(variables.less,"compileLess");
		var actual = variables.less.compileLess(less,true);
		assertEquals(expected, actual);
	}

	public void function testCompileLessFile() {
		var srcFile = expandPath('/farcry/plugins/farcryless/tests/data/test.less');
		var destFile = expandPath('/farcry/plugins/farcryless/tests/data') & '/test.css';
		if (fileExists(destFile)) {
			fileDelete(destFile);
		}
		assertFalse(fileExists(destFile));
		var expected = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.css'));
		makePublic(variables.less, "compileLessFile");
		variables.less.compileLessFile(srcFile, destFile);
		assertTrue(fileExists(destFile));
		var actual = fileRead(destFile);
		fileDelete(destFile);
		assertEquals(expected, actual);
	}

	public void function testCompileLessFileCompressed() {
		var srcFile = expandPath('/farcry/plugins/farcryless/tests/data/test.less');
		var destFile = expandPath('/farcry/plugins/farcryless/tests/data') & '/test.min.css';
		if (fileExists(destFile)) {
			fileDelete(destFile);
		}
		assertFalse(fileExists(destFile));
		var expected = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.min.css'));
		makePublic(variables.less, "compileLessFile");
		variables.less.compileLessFile(srcFile, destFile, true);
		assertTrue(fileExists(destFile));
		var actual = fileRead(destFile);
		fileDelete(destFile);
		assertEquals(expected, actual);
	}

	public void function testGetJavaLoader() {
		assertFalse(structKeyExists(application.stPlugins.farcryless,"javaloader"));
		makePublic(variables.less,"getJavaLoader");
		var javaloader = variables.less.getJavaLoader();
		assertTrue(structKeyExists(application.stPlugins.farcryless,"javaloader"));
		assertTrue(isInstanceOf(application.stPlugins.farcryless.javaloader,"farcry.core.packages.farcry.javaloader.JavaLoader"));
		assertSame(javaloader, variables.less.getJavaLoader());
	}

	public void function testGetLessEngine() {
		assertFalse(structKeyExists(application.stPlugins.farcryless,"lessengine"),"LessEngine already exists in application scope");
		makePublic(variables.less,"getLessEngine");
		var lessengine = variables.less.getLessEngine();
		assertTrue(structKeyExists(application.stPlugins.farcryless,"lessengine"), "Could not create LessEngine in application scope");
		assertEquals("com.asual.lesscss.LessEngine", getMetadata(application.stPlugins.farcryless.lessengine).getName(), "LessEngine is not an instance of com.asual.lesscss.LessEngine");
		assertSame(lessengine, variables.less.getLessEngine(), "getLessEngine did not use the cached copy of the LessEngine");
	}

	public void function testCleanIdForDirName() {
		makePublic(variables.less,"cleanIdForDirName");
		var str = "(*&$(*&$___(test)___*&@##_____123____($*&^@)___(*$(*&$)";
		var expected = "test_123";
		var actual = variables.less.cleanIdForDirName(str);
		assertEquals(expected, actual);
	}

	public void function testGetLibrary() {
		var stCss = {
			id = "test",
			baseHREF = expandPath('/farcry/plugins/farcryless/tests/data'),
			lFiles = "test.less",
			media = "all",
			append = "",
			prepend = "",
			condition = "",
			bCombine = true
		};
		application.stPlugins["farcryless"].stLessLibraries["test"] = stCss;
		assertStructEquals(stCss, variables.less.getLibrary("test"));
	}

	public void function testIsLibraryCompiled() {

		var outputDir = expandPath(application.fapi.getwebroot() & '/') & 'less-output-test/test';
		if (directoryExists(outputDir)) {
			directoryDelete(outputDir, true);
		}

		application.stPlugins["farcryless"].stLessLibraries["test"] = {
			id = "test",
			baseHREF = expandPath('/farcry/plugins/farcryless/tests/data'),
			lFiles = "test.less",
			media = "all",
			append = "",
			prepend = "",
			condition = "",
			bCombine = true
		};

		// make sure its not compiled
		var result = variables.less.isLibraryCompiled("test", "/less-output-test");
		assertFalse(result,"Library should not have been compiled but it was!");

		// compile it
		variables.less.compileLessLibrary("test", "/less-output-test");

		// check again
		result = variables.less.isLibraryCompiled("test", "/less-output-test");
		assertTrue(result,"Library should have been compiled but it was not!");

	}

	public void function testBootstrapCompile() {

		// bootstrap is a large LESS implementation, its a good case for a compile test
		var srcPath = expandPath('/farcry/plugins/farcryless/tests/data/bootstrap/less/bootstrap.less');
		makePublic(variables.less,"compileLessFile");

		// compile bootstrap
		var expected = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.bootstrap.css'));
		var actual = variables.less.compileLessFile(srcPath);
		assertEquals(expected, actual);

		// compile responsive.less
		srcPath = expandPath('/farcry/plugins/farcryless/tests/data/bootstrap/less/responsive.less');
		actual = variables.less.compileLessFile(srcPath);
		expected = fileRead(expandPath('/farcry/plugins/farcryless/tests/data/expected.responsive.css'));
		assertEquals(expected, actual);

	}

}