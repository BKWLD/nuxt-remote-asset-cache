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
	await parallelLimit tasks, options.concurrency
	logger.success 'Downloading to cache complete'

# Check if an asset has already been downloaded
isNewAsset = ({ newPath }, callback) ->
	fs.access makeDest(newPath), (err) -> callback null, !!err

# Make the local path given a remote URL
makeDest = (url) -> path.join options.cacheDir, url

# Download an asset to the cache directory if it's new. Not using async/await in
# here because parallelLimit() doesn't work with it when it's been transpiled.
downloadAssetToCacheDir = ({ oldUrl, newPath }) -> (callback) ->
	dest = makeDest newPath
	fs.ensureDirSync path.dirname dest # Make the directory path
	axios oldUrl, responseType: 'stream'
	
	# Save the file
	.then (response) -> 
		stream = fs.createWriteStream dest
		stream.on 'finish', callback
		stream.on 'error', (error) ->
			logger.error "Error writing #{oldUrl} to #{dest}"
			logger.error error
			callback error
		response.data.pipe stream
	
	# Cleanup after errors
	.catch (error) -> 
		logger.error "Error downloading #{oldUrl} to #{dest}"
		logger.error error
		callback error
	
# Publish the cache contents to the public directory
publishCache = -> 
	logger.info "Publishing the cache directory"
	fs.copySync options.cacheDir, options.publicDir, 
		overwrite: true
	logger.success "Publishing cache directory complete"
	