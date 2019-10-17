# Deps
import logger from './logger'
import { foundAssets, options } from './store'
import parallelLimit from 'async/parallelLimit'
import filter from 'async/filter';
import path from 'path'
import axios from 'axios'
import fs from 'fs-extra'

# Download new remote assets to the cache and then publish all
export default ->
	await downloadfoundAssetsToCacheDir()
	publishCache()
	
# Download URLs to the cache directory
downloadfoundAssetsToCacheDir = ->
	newAssets = await filter foundAssets, isNewAsset
	logger.info "Downloading #{newAssets.length} asset(s) to cache, 
		#{options.concurrency} at a time"
	tasks = newAssets.map downloadAssetToCacheDir
	try await parallelLimit tasks, options.concurrency
	catch e then logger.warn 'Download errors were encountered'
	logger.success 'Downloading to cache complete'

# Check if an asset has already been downloaded
isNewAsset = ({ newUrl }, callback) ->
	fs.access makeDest(newUrl), (err) -> callback null, !!err

# Make the local path given a remote URL
makeDest = (url) -> path.join options.cacheDir, url

# Download an asset to the cache directory if it's new. Not using async/await in
# here because parallelLimit() doesn't work with it when it's been transpiled.
downloadAssetToCacheDir = ({ oldUrl, newUrl }) -> (resolve) ->
	dest = makeDest newUrl
	fs.ensureDirSync path.dirname dest # Make the directory path
	axios oldUrl, responseType: 'stream'
	.then (response) -> response.data.pipe fs.createWriteStream dest
	.catch (error) -> 
		logger.error "Error while downloading #{oldUrl} to #{dest}"
		logger.error error
	.finally -> resolve()
		
	
# Publish the cache contents to the public directory
publishCache = -> 
	logger.info "Publishing the cache directory"
	console.log options.cacheDir, options.publicDir
	fs.copySync options.cacheDir, options.publicDir, 
		overwrite: true
	logger.success "Publishing cache directory complete"
	