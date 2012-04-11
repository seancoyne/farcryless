component {

	/**
	*
	* Registers a LESS library definition
	*
	*/
	public struct function registerLess(required string id, string baseHREF = "", string lFiles = "", string media = "all", string condition = "", string prepend = "", string append = "", boolean bCombine = true) {
		arguments.lFullFilebaseHREFs = "";
		if (len(arguments.lFiles)) {
			arguments.lFullFilebaseHREFs = application.fc.utils.normaliseFileList(arguments.baseHREF,arguments.lFiles);
		}
		var library = duplicate(arguments);
		library.hash = createLibraryHash(library = arguments);
		application.stPlugins.farcryless.stLessLibraries[arguments.id] = library;
		return application.fapi.success("Less library added");
	}

	/**
	*
	* Removes a registered LESS library from the known libraries
	*
	*/
	public void function unregisterLess(required string id) {
		structDelete(application.stPlugins["farcryless"].stLessLibraries, arguments.id);
	}

	/**
	*
	* Returns the library definition of the registered LESS library.
	*
	*/
	public struct function getLibrary(required string id) {
		return application.stPlugins["farcryless"].stLessLibraries[arguments.id];
	}

	/**
	*
	* Returns a struct suitable for passing to skin:loadCSS to serve the compiled CSS files
	*
	*/
	public struct function getCompiledLibrary(required string id, required string outputDir) {
		var library = getLibrary(arguments.id);
		var cleanId = cleanIdForDirName(library.id);
		var result = {
			id = library.id,
			baseHREF = application.fapi.getwebroot() & arguments.outputDir & "/" & cleanId,
			lFiles = "",
			media = library.media,
			condition = library.condition,
			prepend = "",
			append = "",
			bCombine = library.bCombine,
			lCombineIDs = "",
			hostname = ""
		};

		if (structKeyExists(library,"compiled")) {
			result.prepend = library.compiled.prepend;
			result.append = library.compiled.append;
		}

		var files = listToArray(library.lFiles);
		var pathFromWebRoot = arguments.outputDir;
		if (left(arguments.outputDir,1) eq '/') {
			pathFromWebRoot = right(arguments.outputDir,len(arguments.outputDir)-1);
		}
		var fullOutputDir = expandPath(application.fapi.getwebroot() & '/') & pathFromWebRoot & "/" & cleanId;
		var baseDir = library.baseHREF;
		var files = listToArray(library.lFiles);
		for (var i = 1; i lte arrayLen(files); i++) {
			var filePath = baseDir & '/' & files[i];
			var filename = getFileFromPath(filePath);
			var newFilename = reverse(listRest(reverse(filename),".")) & ".css";
			result.lFiles = listAppend(result.lFiles, newFilename);
		}

		return result;
	}

	/**
	*
	* Checks if a registered LESS library has been compiled.  It confirms this by checking for compiled append/prepend
	* values, and then that each file of the LESS library has a compiled CSS version on disk in the specified output
	* directory.
	*
	*/
	public boolean function isLibraryCompiled(required string id, required string outputDir) {
		if (isRegistered(arguments.id)) {
			var library = getLibrary(arguments.id);

			// check that any append/prepend values exist in the library cache
			if (len(trim(library.append))) {
				if (!structKeyExists(library,"compiled")) {
					return false;
				}
				if (!structKeyExists(library.compiled,"append")) {
					return false;
				}
				if (!len(trim(library.compiled.append))) {
					return false;
				}
			}
			if (len(trim(library.prepend))) {
				if (!structKeyExists(library,"compiled")) {
					return false;
				}
				if (!structKeyExists(library.compiled,"prepend")) {
					return false;
				}
				if (!len(trim(library.compiled.prepend))) {
					return false;
				}
			}

			// check that all less files have css counter parts
			var files = listToArray(library.lFiles);

			var pathFromWebRoot = arguments.outputDir;
			if (left(arguments.outputDir,1) eq '/') {
				pathFromWebRoot = right(arguments.outputDir,len(arguments.outputDir)-1);
			}
			// clean up the id
			var cleanId = cleanIdForDirName(library.id);
			var fullOutputDir = expandPath(application.fapi.getwebroot() & '/') & pathFromWebRoot & "/" & cleanId;
			var baseDir = library.baseHREF;
			var files = listToArray(library.lFiles);
			for (var i = 1; i lte arrayLen(files); i++) {
				var filePath = baseDir & '/' & files[i];
				var filename = getFileFromPath(filePath);
				var newFilename = reverse(listRest(reverse(filename),".")) & ".css";
				if (!fileExists(fullOutputDir & "/" & newFileName)) {
					return false;
				}
			}

			return true;

		}

		return false;
	}

	/**
	*
	* Returns true if there is a registered LESS library with the specified ID.  Returns false otherwise.
	*
	*/
	public boolean function isRegistered(required string id) {
		return structKeyExists(application.stPlugins["farcryless"].stLessLibraries, arguments.id);
	}

	/**
	*
	* Compiles a FarCry Less Library.  Writes compiled CSS files to the output directory,
	* returns a struct that can be passed to the "attributeCollection" of a skin:loadCSS
	* tag.
	*
	* @stLess 		a struct containing the LESS library configuration details.  This is created by the registerLess
	*				function and custom tag and can be retrieved using the getLibrary method.
	* @outputDir	the path, relative to the webroot, where the compiled CSS files should be written
	*
	*/
	public struct function compileLessLibrary(required string id, required string outputDir) {

		var stLess = getLibrary(id);

		if (!structKeyExists(stLess,"compiled")) {
			stLess.compiled = { append = "", prepend = "" };
		}

		// clean up the id
		var cleanId = cleanIdForDirName(stLess.id);

		var result = {
			id = stLess.id,
			baseHREF = application.fapi.getwebroot() & arguments.outputDir & "/" & cleanId,
			lFiles = "",
			media = stLess.media,
			condition = stLess.condition,
			prepend = "",
			append = "",
			bCombine = stLess.bCombine,
			lCombineIDs = "",
			hostname = ""
		};

		if (len(trim(stLess.append))) {
			// if append is specified, then compile as a string, save as the "append" value in result struct
			result.append = compileLess(less = stLess.append);
			stLess.compiled.append = result.append;
		}

		if (len(trim(stLess.prepend))) {
			// if append is specified, then compile as a string, save as the "prepend" value in the result struct
			result.prepend = compileLess(less = stLess.prepend);
			stLess.compiled.prepend = result.prepend;
		}

		// compile each less file into a corresponding CSS file
		var pathFromWebRoot = result.baseHREF;
		if (left(result.baseHREF,1) eq '/') {
			pathFromWebRoot = right(result.baseHREF,len(result.baseHREF)-1);
		}
		var fullOutputDir = expandPath(application.fapi.getwebroot() & '/') & pathFromWebRoot;
		if (!directoryExists(fullOutputDir)) {
			directoryCreate(fullOutputDir);
		}
		var baseDir = stLess.baseHREF;
		var files = listToArray(stLess.lFiles);
		for (var i = 1; i lte arrayLen(files); i++) {
			var filePath = baseDir & '/' & files[i];
			if (fileExists(filePath)) {
				var filename = getFileFromPath(filePath);
				var newFilename = reverse(listRest(reverse(filename),".")) & ".css";
				compileLessFile(filePath, fullOutputDir & '/' & newFilename);
				result.lFiles = listAppend(result.lFiles, newFilename);
			} else {
				throw (type = "FileDoesntExist", message = "File #filePath# does not exist!");
			}
		}

		return result;
	}

	/**
	*
	* Compiles a less file, optionally compressing and writing the resulting CSS to a destination file
	*
	*/
	private any function compileLessFile(required string fullPathToSource, string fullPathToDestination, boolean compress = false) {
		var lessEngine = getLessEngine();
		var srcFile = createObject("java","java.io.File").init(arguments.fullPathToSource);
		if (structKeyExists(arguments,"fullPathToDestination")) {
			// write compiled string to destination file
			if (!fileExists(arguments.fullPathToDestination)) {
				fileWrite(arguments.fullPathToDestination,"");
			}
			var destFile = createObject("java","java.io.File").init(arguments.fullPathToDestination);
			lessEngine.compile(srcFile, destFile, javacast("boolean",arguments.compress));
			return;
		} else {
			// return the compiled string
			return lessEngine.compile(srcFile, javacast("boolean",arguments.compress));
		}
	}

	/**
	*
	* Compiles a less string and optionally compresses the resulting CSS
	*
	*/
	private any function compileLess(required string less, boolean compress = false) {
		var lessEngine = getLessEngine();
		return lessEngine.compile(javacast('string', arguments.less), javacast('boolean', arguments.compress));
	}

	// helper methods

	private any function getJavaLoader() {
		if (!structKeyExists(application.stPlugins["farcryless"],"javaloader")) {
			var paths = [
				expandPath('/farcry/plugins/farcryless/packages/custom/lib/lesscss-engine-1.3.1.jar'),
				expandPath('/farcry/plugins/farcryless/packages/custom/lib/js.jar')
			];
			application.stPlugins["farcryless"].javaloader = createObject("component","farcry.core.packages.farcry.javaloader.JavaLoader").init(
				loadPaths = paths,
				loadColdFusionClassPath = true
			);
		}
		return application.stPlugins["farcryless"].javaloader;
	}

	private any function getLessEngine() {
		if (!structKeyExists(application.stPlugins["farcryless"],"lessengine")) {
			application.stPlugins["farcryless"].lessengine = getJavaLoader().create("com.asual.lesscss.LessEngine").init();
		}
		return application.stPlugins["farcryless"].lessengine;
	}

	private string function cleanIdForDirName(required str) {

		// clean any non-alphanumeric, non-underscore chars
		var newStr = reReplaceNoCase(arguments.str, "[^0-9a-z_]","_","ALL");

		// remove double underscores
		newStr = reReplaceNoCase(newStr, "(_){1,}","_","ALL");

		// remove underscores at the beginning or end
		newStr = reReplaceNoCase(newStr, "(^_|_$)","","ALL");

		return newStr;
	}

	public string function createLibraryHash(required struct library) {
		return hash(arguments.library.baseHref & arguments.library.lFiles & arguments.library.append & arguments.library.prepend, "md5", "utf-8");
	}

}