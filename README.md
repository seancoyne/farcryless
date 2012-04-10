# FarCry LESS
## A LESS compiler plugin for FarCry

Sean Coyne [http://www.n42designs.com](http://www.n42designs.com)
Licensed under [Apache License, Version 2.0](https://github.com/seancoyne/farcryless/blob/master/LICENSE)

This plugin for the [FarCry](http://www.farcrycore.org/) framework allows you to use [LESS](http://lesscss.org/) code directly in FarCry and the plugin will automatically compile it to CSS. Each LESS file is compiled into a corresponding CSS file which are then loaded via FarCry's built in `<skin:loadCSS ... />` functionality. The plugin is smart enough to determine if defined LESS libraries have already been compiled.  Compilation only happens on the first request so there is very little overhead, and since compilation happens on the server side, you take the load off your user's browser when compared to using [less.js](http://lesscss.org/#-client-side-usage).

## Requirements

* [ColdFusion 9.0.1+](http://www.adobe.com/go/coldfusion) or [Railo 3.3.2+](http://getrailo.org/)
* [FarCry 6.1.4+](http://www.farcrycore.org/)
* [Less CSS Engine 1.3.1](http://www.asual.com/lesscss/) (included)
* [Mozilla Rhino 1.7R3](http://www.mozilla.org/rhino/) (included)

## Installation

### Using Git

From your /farcry/plugins directory clone from github by executing:

    git clone git://github.com/seancoyne/farcryless.git

This will clone the latest version of the plugin into a directory at /farcry/plugins/farcryless/

### Using Zip or Tarball Downlaod

Extract archive to /farcry/plugins/farcryless/

### Continuing Installation...

1. Add __farcryless__ to the list of plugins in your farcryConstructor.cfm file
2. Update App (either via the webtop utility or hit http://mysite.com/?updateapp=\[updateappkey\])
3. Log into the webtop and go to Admin -> "Edit Config" -> "LESS Compiler" and edit the configuration.  You can specify a specific directory under the webroot where compiled CSS files will be stored.  This path is relative to the webroot.  If deploying to an existing site with CSS files then I suggest using a different path to avoid conflicts. Something like /css/less-output or similar will work just fine.  If deploying to a new site, and you will use LESS exclusively then /css will work as well.

## Usage

To register a library, use the included `<less:registerLess ... />` tag.  This will allow you to use the same LESS library in multiple webskins without having to specify the `baseHREF` and `lFiles` attributes each time.

Unlike FarCry's built-in `<skin:registerCSS ... />` tag, the `baseHREF` attribute should be the full path to the LESS files directory.  Since LESS files are source code, most would not want them to live under the webroot.  This allows you to keep the original source secure and out of the webroot.  Like the built in tag, the `baseHREF` should not include a trailing `/`.

For example, you could include this in your _serverSpecificVarsAfterInit.cfm:

```cfml
<cfimport taglib="/farcry/plugins/farcryless/tags/less" prefix="less" />
<less:registerLess id="myLibrary" baseHref="#expandPath('/farcry/projects/myproject/less')#" lFiles="file1.less, file2.less" />
```

Then in your webskins you can load the compiled CSS like this:

```cfml
<cfimport taglib="/farcry/plugins/farcryless/tags/less" prefix="less" />
<less:loadLess id="myLibrary" />
```

If you prefer, you can register and load the LESS library at the same time using only the loadLess tag.  I recommend registering it separately, but this will work just fine:

```cfml
<cfimport taglib="/farcry/plugins/farcryless/tags/less" prefix="less" />
<less:loadLess id="myLibrary" baseHref="#expandPath('/farcry/projects/myproject/less')#" lFiles="file1.less, file2.less" />
```

If you modify the source LESS files, the plugin will not automatically recompile them. To force a recompile, delete the compiled CSS files from the output directory you specified in the configuration.  You will also have to delete the minified CSS files that FarCry creates in the "cache" directory, the same as you would if you had modified a normal CSS file.  Optionally, there is a configuration setting to "Always Recompile".  Checking this will force the loadCSS tag to always recompile the LESS library on each request.  This is not recommended for production use, but is helpful during development.  You will still need to clear the "cache" directory of the minified CSS files, however.

## Acknowledgements

* [Asual LESS for Java](http://www.asual.com/lesscss/) included, released under the [Apache License 2.0](https://github.com/seancoyne/farcryless/blob/master/packages/custom/lib/lesscss-engine-LICENSE)
* [Mozilla Rhino](http://www.mozilla.org/rhino/) included, released under the [Multiple Licenses](https://github.com/seancoyne/farcryless/blob/master/packages/custom/lib/Rhino-LICENSE.txt);

Special thanks to:

* [Daemon](http://www.daemon.com.au/) for [FarCry](http://www.farcrycore.org/)
* [Mark Mandel](http://www.compoundtheory.com/) for [JavaLoader](https://github.com/markmandel/JavaLoader)
* [Alexis Sellier](http://cloudhead.io/) for [Less](https://github.com/cloudhead/less.js)

## Known issues or limitations

See the [issue tracker](https://github.com/seancoyne/farcryless/issues) for more details or additional issues not listed here.

* The included `<less:loadLess ... />` tag does not support the `lCombineIDs` attribute like its `<skin:loadCSS ... />` counterpart.  So, you cannot load multiple LESS libraries in a single `<less:loadLess ... />` call. It also does not support loading external LESS files using the `hostname` attribute, or by specifying a URL in the `baseHREF` attribute. Perhaps this will be added in the future, if you are interested in this or any other new features please [log a bug](https://github.com/seancoyne/farcryless/issues), or even better, fork this repository, add the functionality and send me a pull request :)

## Contributions

Contributions are always welcome.  Please use Github's pull request functionality to submit your patches.  If you add or modify any existing functionality be sure to include unit tests.  Any changes that break the unit tests will not be accepted.