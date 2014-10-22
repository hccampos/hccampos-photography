_ = require('lodash')
Promise = require('promiscuous')
LoadUtils = require('./common/LoadUtils')
Router = require('./Router')
BaseView = require('./BaseView')
HomeView = require('./home/HomeView')
AlbumView = require('./album/AlbumView')

AppView = BaseView.extend
	el: document.body
	template: require('./main.hbs')

	_transitionPromise: null

	initialize: (options) ->
		@router = new Router(app: @)

		# Preload all the albums and the associated photo lists so the site feels
		# more responsive.
		@_albums = null
		@loadAlbums().then (albums) =>
			@loadPhotos(album.id) for album in albums

	###
	Loads the list of albums from the server and caches it. If we already have
	the data in cache, we resolve right away.

	Returns {Promise}
	###
	loadAlbums: ->
		if @_albums? then return Promise.resolve(@_albums)

		LoadUtils.loadJSON('https://dl.dropboxusercontent.com/u/2988676/hccphoto/albums.json')
		.then (albums) =>
			@_albums ?= albums
			return @_albums

	###
	Loads the list of photos for the specified album. If we already have the data
	in cache, we resolve right away.

	Returns {Promise}
	###
	loadPhotos: (album) ->
		albumId = album.id ? album
		cachedAlbum = @getCachedAlbum(albumId)

		# If we don't have the album we have to load it.
		if not cachedAlbum?
			return @loadAlbums().then =>
				@loadPhotos(album)

		# If we already have the photos, just resolve with them. Otherwise we
		# will have to load them.
		if cachedAlbum.photos?
			return Promise.resolve(cachedAlbum.photos)

		LoadUtils.loadJSON("https://dl.dropboxusercontent.com/u/2988676/hccphoto/#{albumId}.json")
		.then (photos) =>
			cachedAlbum.photos = photos
			return photos

	###
	Gets an album from the cache by id.

	Returns {Album}
	###
	getCachedAlbum: (id) ->
		_.find @_albums, (a) -> "#{a.id}" == "#{id}"

	###
	Shows the list of all the albums.
	###
	showAlbums: ->
		@closeAlbumLinkEl?.classList.add('hidden')
		@albumTitleEl?.classList.add('hidden')

		@loadAlbums().then =>
			@goto(new HomeView(albums: @_albums), true)

	###
	Shows an album and, optionally, a photo of that album.

	{string} albumId
		The id of the album which is to be shown.
	{string} photoId
		The id of the photo which is to be shown.
	###
	showAlbum: (albumId, photoId) ->
		# We are in the same album, only viewing a different photo...
		if @currentView instanceof AlbumView and @currentView.data.id == albumId
			return @currentView.showPhoto(photoId)

		@loadPhotos(albumId).then =>
			album = @getCachedAlbum(albumId)

			view = new AlbumView
				app: @
				id: album.id
				album: album

			@saveScrollPosition()

			@goto(view).then =>
				@closeAlbumLinkEl?.classList.remove('hidden')
				@albumTitleEl?.innerHTML = album.name
				@albumTitleEl?.classList.remove('hidden')

				view.showPhoto(photoId ? photos?[0]?.id)
		, (error) =>
			@router.navigate('/')

	###
	Saves the scroll position so we can restore it later.
	###
	saveScrollPosition: ->
		@_scrollPos = document.body.scrollTop

	###
	Restores the scroll position to the last saved value.
	###
	restoreScrollPosition: ->
		if @_scrollPos
			document.body.scrollTop = @_scrollPos

	###
	Renders the app and grabs some necessary DOM elements.
	###
	render: ->
		@el.innerHTML = @template()
		@viewEl = @el.querySelector('.view')
		@closeAlbumLinkEl = @el.querySelector('a.close-album')
		@albumTitleEl = @el.querySelector('header .album-title')
		return @

	###
	Transitions to the specified page view.

	{BaseView} view
		The view to which the app should transition.
	###
	goto: (view, restoreScrollPosition=false) ->
		if @_transitionPromise?
			# If we are transitioning, let's wait for the transition to complete
			# and then do the new transition.
			return @_transitionPromise.then =>
				@goto(view)

		previous = @currentPage ? null
		next = view

		transitionNextIn = =>
			next.render(page: true)
			@viewEl.appendChild(next.el)
			@currentPage = next
			if restoreScrollPosition
				@restoreScrollPosition()
			return next.transitionIn()

		if previous?
			@_transitionPromise = previous.transitionOut()
			.then =>
				previous.remove()
				transitionNextIn()
		else
			@_transitionPromise = transitionNextIn()

		@_transitionPromise = @_transitionPromise.then =>
			@_transitionPromise = null
			return @


module.exports = AppView