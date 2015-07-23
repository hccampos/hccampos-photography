_ = require('lodash')
Hammer = require('hammerjs')
Backbone = require('exoskeleton')
BaseView = require('../BaseView')
PhotoView = require('./photo/PhotoView')

ESC_KEY_CODE = 27
LEFT_KEY_CODE = 37
RIGHT_KEY_CODE = 39

AlbumView = BaseView.extend
	className: 'album'
	template: require('./album-view.hbs')

	events:
		'click .next.arrow-btn': 'nextPhoto'
		'click .prev.arrow-btn': 'prevPhoto'
		'click .photo': 'nextPhoto'

	initialize: (options) ->
		@app = options.app
		delete options.app

		@data = _.extend({}, options)
		@photoViews = []
		@currentPhotoIndex = 0

		@onKeydown = @onKeydown.bind(@)
		document.addEventListener('keydown', @onKeydown)

		@hammer = new Hammer(@el);
		@hammer.get('swipe').set(direction: Hammer.DIRECTION_HORIZONTAL)
		@hammer.on 'swipeleft', =>
			@nextPhoto()
		@hammer.on 'swiperight', =>
			@prevPhoto()

	remove: ->
		document.removeEventListener('keydown', @onKeydown)
		@hammer.destroy()
		Backbone.View.prototype.remove.call(@)

	render: (options) ->
		BaseView.prototype.render.call(@, options)

		galleryEl = @el.querySelector('.photo-container')
		galleryEl.innerHTML = ''

		@photoViews = []

		for photo in @data.album.photos
			photoView = new PhotoView(photo)
			photoView.render()
			photoView.hide(true)
			galleryEl.appendChild(photoView.el)
			@photoViews.push(photoView)

		return @

	showPhoto: (id) ->
		id = id?.toString()
		id ?= '1'

		for photoView, index in @photoViews
			photoId = photoView.data.id.toString()
			if photoId == id
				@currentPhotoIndex = index

				# Preload the previous and next photos.
				@preloadPhotoAt(@getNextIndex(-1))
				@preloadPhotoAt(@getNextIndex(1))

				photoView.show()
				@app.router.navigate("/albums/#{@data.album.id}/#{photoId}", {trigger: false});
			else
				photoView.hide()

	showPhotoAt: (index) ->
		@showPhoto(@data.album.photos[index].id)

	preloadPhotoAt: (indexToPreload) ->
		id = @data.album.photos[indexToPreload].id?.toString()
		return unless id?

		for photoView, index in @photoViews
			photoId = photoView.data.id.toString()
			if photoId == id then photoView.preloadImage()

	nextPhoto: ->
		@currentPhotoIndex = @getNextIndex(1)
		@showPhotoAt(@currentPhotoIndex)

	prevPhoto: ->
		@currentPhotoIndex = @getNextIndex(-1)
		@showPhotoAt(@currentPhotoIndex)

	getNextIndex: (dir) ->
		count = @getNumPhotos()
		(@currentPhotoIndex + dir + count) % count

	getNumPhotos: ->
		return @data.album.photos?.length ? 0

	onKeydown: (event) ->
		if event.keyCode == LEFT_KEY_CODE
			@prevPhoto()
		else if event.keyCode == RIGHT_KEY_CODE
			@nextPhoto()
		else if event.keyCode == ESC_KEY_CODE
			@app.router.home()


module.exports = AlbumView