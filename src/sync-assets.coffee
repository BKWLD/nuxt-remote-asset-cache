# Deps
import logger from './logger'
import { remoteUrls } from './store'
import parallelLimit from 'async/parallelLimit'
import path from 'path'
import axios from 'axios'
import fs from 'fs-extra'

# Settings
concurrency = 6
cacheNamespaceDir = 'remote-assets'
cacheDir = path.join __dirname, '../test/cache', cacheNamespaceDir
publicDir = path.join __dirname, '../test/public'
pattern = /https?:\/\/craft\.infotechinc\.com\/images\/([\w\d-.]+)/i
replacement = '/images/$1'

# Download new remote assets to the cache and then publish all
export default ->
	await downloadNewAssetsToCacheDir()
	await publishCache()
	
# Download URLs to the cache directory
downloadNewAssetsToCacheDir = ->
	logger.info "Downloading #{remoteUrls.length} assets (if new) to cache, 
		#{concurrency} at a time"
	logger.debug "Cache directory: #{cacheDir}"
	tasks = remoteUrls.map downloadAssetToCacheDir
	await parallelLimit tasks, concurrency
	logger.success 'Downloading to cache complete'

# Download an asset to the cache directory
downloadAssetToCacheDir = (url) -> -> # parallelLimit needs a function
	dest = getDestFromUrl url
	return if fs.existsSync dest
	fs.ensureDirSync path.dirname dest # Make the directory path
	response = await axios url, responseType: 'stream'
	response.data.pipe fs.createWriteStream dest
	
# Return the absolute path where the asset will be downloaded to
getDestFromUrl = (url) ->
	nonGlobalPattern = RegExp pattern.source, pattern.flags.replace 'g', ''
	[ url, filename ] = url.match nonGlobalPattern
	publicPath = replacement.replace '$1', filename
	dest = path.join cacheDir, publicPath
	
# Publish the cache to the public directory
publishCache = -> 
	logger.info "Publishing the cache directory"
	logger.debug "Public directory: #{publicDir}"
	fs.copySync cacheDir, publicDir
	logger.success "Publishing cache directory complete"
	