Promise = require('promiscuous')

###
Loads a JSON file from the specified url.

{string} url
	The url from which the file is to be loaded.

Returns {Promise}
	A promise which is resolved with the parsed file contents when it has
	been loaded.
###
loadJSON = (url) ->
	new Promise (resolve, reject) ->
		request = new XMLHttpRequest()
		request.open('get', url, true)

		request.onreadystatechange = ->
			if request.readyState == 4 # Ready
				if (request.status == 200)
					try
						data = JSON.parse(request.responseText)
					catch
						data = request.responseText
					resolve(data)
				else
					reject(new Error('Could not load file'))

		request.send()


###
Loads an image and resolves when the image has been loaded.

{string} url
	The url of the image which is to be loaded.
{Image|HTMLImageElement} [imgElement]
	The image element used to load the image. If none is provided one will
	be automatically created.

Returns {Promise}
	A promise which is resolved with the image element that was used to load
	the image.
###
loadImage = (url, imgElement) ->
	imgElement ?= new Image()

	return new Promise (resolve, reject) ->
		removeListeners = ->
			imgElement.removeEventListener('load', onLoad)
			imgElement.removeEventListener('abort', onError)
			imgElement.removeEventListener('error', onError)

		onLoad = ->
			removeListeners()
			resolve(imgElement)

		onError = (error) ->
			removeListeners()
			reject(error)

		imgElement.addEventListener('load', onLoad)
		imgElement.addEventListener('abort', onError)
		imgElement.addEventListener('error', onError)
		imgElement.src = url

#-------------------------------------------------------------------------------

module.exports = {
	loadJSON
	loadImage
}