_ = require('lodash')
Promise = require('promiscuous')
BaseView = require('../BaseView')
LoadUtils = require('../common/LoadUtils')

LOADED_CLASS = 'loaded'
LOADING_CLASS = 'loading'


AlbumView = BaseView.extend
	tagName: 'li'
	className: 'album'
	template: require('./album.hbs')
	data: {}

	initialize: (options) ->
		_.extend(@data, options)

	render: ->
		BaseView.prototype.render.call(@)
		@setCover(@data.cover)
		return @

	setCover: (src) ->
		if not src? then return Promise.resolve()

		el = @el # So we don't have to use @ in a bunch of places.
		el.classList.remove(LOADED_CLASS)
		el.classList.add(LOADING_CLASS)

		LoadUtils.loadImage(src)
		.then ->
			el.classList.remove(LOADING_CLASS)
			el.classList.add(LOADED_CLASS)

			coverEl = el.querySelector('.cover')
			if coverEl
				coverEl.style.backgroundImage = "url('#{src}')"


module.exports = AlbumView