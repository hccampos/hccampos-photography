_ = require('lodash')
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

	loadAlbums: ->
		LoadUtils.loadJSON('https://dl.dropboxusercontent.com/u/2988676/hccphoto/albums.json')

	loadAlbum: (album) ->
		id = album.id ? album
		LoadUtils.loadJSON("https://dl.dropboxusercontent.com/u/2988676/hccphoto/#{id}.json")

	###
	Shows the list of all the albums.
	###
	showAlbums: ->
		@closeAlbumLinkEl?.classList.add('hidden')
		@albumTitleEl?.classList.add('hidden')

		@loadAlbums()
		.then (albums) =>
			@goto(new HomeView(albums: albums))

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

		album = null

		@loadAlbums().then (albums) =>
			album = _.find albums, (a) -> "#{a.id}" == "#{albumId}"
			@loadAlbum(album)
		.then (photos) =>
			view = new AlbumView
				app: @
				id: album.id
				album: album
				photos: photos

			@goto(view).then =>
				@closeAlbumLinkEl?.classList.remove('hidden')
				@albumTitleEl?.innerHTML = album.name
				@albumTitleEl?.classList.remove('hidden')

				view.showPhoto(photoId ? photos?[0]?.id)
		, (error) =>
			@router.navigate('/')

	render: ->
		@el.innerHTML = @template()
		@viewEl = @el.querySelector('.view')
		@closeAlbumLinkEl = @el.querySelector('a.close-album')
		@albumTitleEl = @el.querySelector('header .album-title')
		return @

	goto: (view) ->
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
			next.transitionIn()

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