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

	album: (albumId) ->
		@app.showAlbum(albumId)

	photo: (albumId, photoId) ->
		@app.showAlbum(albumId, photoId)

module.exports = Router