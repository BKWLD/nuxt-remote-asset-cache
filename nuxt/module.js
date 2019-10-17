// Deps
import path from 'path'
import syncAssets from '../dist/sync-assets'
import { setOptions } from '../dist/store'
import logger from '../dist/logger'

// Module deps
module.exports = function (moduleOptions) {
	
	// Add the plugin that adds the $cacheAssets function regardless of whether
	// generating or not.  If not generating, the $cacheAssets method will just
	// passthrough the data
	this.addPlugin({
		src: path.resolve(__dirname, 'cache-assets-plugin.js'),
	});
	
	// Proceed no further if not generating
	if (process.env.npm_lifecycle_event !== 'generate') return;
	
	// Set options
	const options = setOptions(this.options, moduleOptions);
	
	// Require a cache dir
	if (!options.cacheDir) {
		return logger.info("Remote assets NOT cached because no cacheDir");
	}
	
	// When generation is done, cache remote assets that were captured by the
	// plugin.
	this.nuxt.hook('generate:done', syncAssets);
}

// Export meta for Nuxt
module.exports.meta = require('../package.json')