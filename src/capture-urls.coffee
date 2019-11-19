# Deps (needed to be CJS style...)
import logger from './logger'
import { foundAssets, options } from './store'

# Capture all the remote asset URLs and update them to a local path from an
# object of data
export default (data) ->
	
	# Don't act unless generating
	return data unless process.env.npm_lifecycle_event == 'generate'
	
	# Stringify the data for easy replacing
	urlsFound = foundAssets.length
	text = JSON.stringify data
	
	# Loop through each pattern and replace asset URLs
	for { pattern, replacement } in options.assetRegex
		text = text.replace pattern, (oldUrl, filename) ->
			
			# Make the new URL using the replacement
			newPath = replacement.storagePath.replace '$1', filename
			newUrl = replacement.publicUrl.replace '$1', filename
			
			# If this URL hasn't been found yet, add it to the list to be downloaded
			unless foundAssets.find (asset) -> asset.oldUrl == oldUrl
				foundAssets.push { oldUrl, newPath }
				
			# Replace the old URL with the new one
			return newUrl
	
	# Update the log
	logger.info "Found #{foundAssets.length - urlsFound} asset(s)"

	# Return updated object
	return JSON.parse text
