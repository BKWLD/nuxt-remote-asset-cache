# Deps
import logger from './logger'
import { remoteUrls } from './store'
import parallelLimit from 'async/parallelLimit'
import path from 'path'
import axios from 'axios'
import fs from 'fs'
import mkdirp from 'mkdirp'

# Settings
concurrency = 6
cacheDir = path.join __dirname, 'test'
pattern = /https?:\/\/craft\.infotechinc\.com\/images\/([\w\d-.]+)/i
replacement = '/images/$1'

###
Download the remote assets
###
export default ->
	await downloadNewAssetsToCacheDir()
	
# Download URLs to the cache directory
downloadNewAssetsToCacheDir = ->
	logger.info "Downloading #{remoteUrls.length} assets (if new) to cache, 
		#{concurrency} at a time"
	logger.info "Cache directory: #{cacheDir}"
	tasks = remoteUrls.map downloadAssetToCacheDir
	await parallelLimit tasks, concurrency
	logger.success 'Downloading to cache complete'

# Download an asset to the cache directory
downloadAssetToCacheDir = (url) -> -> # parallelLimit needs a function
	dest = getDestFromUrl url
	return if fs.existsSync dest
	mkdirp.sync path.dirname dest # Make the directory path
	response = await axios url, responseType: 'stream'
	response.data.pipe fs.createWriteStream dest
	
# Return the absolute path where the asset will be downloaded to
getDestFromUrl = (url) ->
	nonGlobalPattern = RegExp pattern.source, pattern.flags.replace 'g', ''
	[ url, filename ] = url.match nonGlobalPattern
	publicPath = replacement.replace '$1', filename
	dest = path.join cacheDir, publicPath