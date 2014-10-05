LoadUtils = require('./common/LoadUtils')
Backbone = require('exoskeleton')
HomeView = require('./home/HomeView')
AlbumView = require('./album/AlbumView')
PhotoView = require('./photo/PhotoView')

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
		LoadUtils.loadJSON('/data/albums.json')
		.then (albums) =>
			@app.goto(new HomeView(albums: albums))

	album: (id) ->
		@app.goto(new AlbumView())

	photo: (id) ->
		@app.goto(new PhotoView())

module.exports = Router