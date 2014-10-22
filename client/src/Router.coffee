LoadUtils = require('./common/LoadUtils')
Backbone = require('exoskeleton')

Router = Backbone.Router.extend
	initialize: (options) ->
		@app = options.app

		@route('*notfound', 'otherwise')
		@route('', 'home');
		@route('albums/:albumId', 'album')
		@route('albums/:albumId/:photoId', 'photo')

	otherwise: ->
		@navigate '',
			trigger: true
			replace: false

	home: ->
		@app.showAlbums()
		.then null, (error) ->
			console.log(error)

	album: (albumId) ->
		@app.showAlbum(albumId)
		.then null, (error) ->
			console.log(error)

	photo: (albumId, photoId) ->
		@app.showAlbum(albumId, photoId)
		.then null, (error) ->
			console.log(error)

module.exports = Router