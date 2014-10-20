_ = require('lodash')
Backbone = require('exoskeleton')
BaseView = require('../BaseView')
PhotoView = require('./photo/PhotoView')

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

	remove: ->
		document.removeEventListener('keydown', @onKeydown)
		Backbone.View.prototype.remove.call(@)

	render: (options) ->
		BaseView.prototype.render.call(@, options)

		galleryEl = @el.querySelector('.photo-container')
		galleryEl.innerHTML = ''

		@photoViews = []

		for photo in @data.photos
			photoView = new PhotoView(photo)
			photoView.render()
			photoView.hide(true)
			galleryEl.appendChild(photoView.el)
			@photoViews.push(photoView)

		return @

	showPhoto: (id) ->
		id = id?.toString()

		for photoView, index in @photoViews
			photoId = photoView.data.id.toString()
			if photoId == id
				@currentPhotoIndex = index
				photoView.show()
				@app.router.navigate("/albums/#{@data.album.id}/#{photoId}", {trigger: false});
			else
				photoView.hide()

	showPhotoAt: (index) ->
		@showPhoto(@data.photos[index].id)

	nextPhoto: ->
		@currentPhotoIndex++
		if @currentPhotoIndex > (@getNumPhotos() - 1)
			@currentPhotoIndex = 0
		@showPhotoAt(@currentPhotoIndex)

	prevPhoto: ->
		@currentPhotoIndex--
		if @currentPhotoIndex < 0
			@currentPhotoIndex = @getNumPhotos() - 1
		@showPhotoAt(@currentPhotoIndex)

	getNumPhotos: ->
		return @data.photos?.length ? 0

	onKeydown: (event) ->
		if event.keyCode == LEFT_KEY_CODE
			@prevPhoto()
		else if event.keyCode == RIGHT_KEY_CODE
			@nextPhoto()


module.exports = AlbumView