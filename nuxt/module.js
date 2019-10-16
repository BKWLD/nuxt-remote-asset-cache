// Deps
import path from 'path'
import syncAssets from '../dist/sync-assets'
module.exports = function (options) {
	
	// Add the plugin that adds the $cacheAssets functino
	this.addPlugin({
		src: path.resolve(__dirname, 'cache-assets-plugin.js'),
	});
	
	// Download all remote images to cache and public directories
	this.nuxt.hook('generate:done', syncAssets);
}

// Export meta for Nuxt
module.exports.meta = require('../package.json')