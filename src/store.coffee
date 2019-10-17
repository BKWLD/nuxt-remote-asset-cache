###
This file is used to pass data between the module, plugin and the main logic.
It was an approach I arrived at, in part, to work around the restriction on
passing non-scalar values from module to plugin in Nuxt. 
###
import path from 'path'
import logger from './logger'

# New assets that will be downloaded
export foundAssets = []

# Configuration options options
export options = {};

# Set the options, with defaults
export setOptions = (nuxtOptions, moduleOptions = {}) ->

	# Make options with defaults
	options = Object.assign
		cacheDir: null
		assetRegex: []
		concurrency: 6
		namespaceDirname: 'remote-assets'
		publicDir: nuxtOptions.generate.dir
	, nuxtOptions.remoteAssetCache, moduleOptions
		
	# Add the package's namespaced dir to the cache dir
	if options.cacheDir
		options.cacheDir = path.join options.cacheDir, options.namespaceDirname
	
	# Return the options
	return options