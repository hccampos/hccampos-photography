_ = require('lodash')
Promise = require('promiscuous')
BaseView = require('../../BaseView')
LoadUtils = require('../../common/LoadUtils')

LOADED_CLASS = 'loaded'
LOADING_CLASS = 'loading'


HomeAlbumView = BaseView.extend
	tagName: 'li'
	className: 'home-album'
	template: require('./home-album-view.hbs')
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

			coverImgEl = el.querySelector('.cover .img')
			if coverImgEl
				coverImgEl.style.backgroundImage = "url('#{src}')"


module.exports = HomeAlbumView