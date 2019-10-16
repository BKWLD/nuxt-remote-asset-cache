# Deps (needed to be CJS style...)
logger = require('./logger').default
{ remoteUrls } = require './store'

###
Capture all the remote asset URLs and update them to a local path from an
# object of data
###
module.exports = (data) ->
	
	# Don't act unless generating
	return data unless process.env.npm_lifecycle_event == 'generate'
	
	# Options (needs to be moved into config)
	pattern = /https?:\/\/craft\.infotechinc\.com\/images\/([\w\d-.]+)/gi
	replacement = '/images/$1'
	
	# Stringify the data for easy replacing
	urlsFound = remoteUrls.length
	text = JSON.stringify data
	text = text.replace pattern, (url, filename) ->
		remoteUrls.push url unless remoteUrls.includes url
		publicPath = replacement.replace '$1', filename
		return publicPath
	
	# Update the log
	logger.info "Found #{remoteUrls.length - urlsFound} new assets"

	# Return updated object
	return JSON.parse text
