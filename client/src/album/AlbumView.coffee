_ = require('lodash')
BaseView = require('../BaseView')
PhotoView = require('./photo/PhotoView')


AlbumView = BaseView.extend
	className: 'album'
	template: require('./album-view.hbs')

	initialize: (options) ->
		@data = _.extend({}, options)
		@photoViews = []

	render: (options) ->
		BaseView.prototype.render.call(@, options)

		galleryEl = @el.querySelector('.gallery')
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

		for photoView in @photoViews
			photoId = photoView.data.id.toString()
			if photoId == id then photoView.show() else photoView.hide()


module.exports = AlbumView