_ = require('lodash')
Promise = require('promiscuous')
BaseView = require('../../BaseView')
LoadUtils = require('../../common/LoadUtils')


LOADED_CLASS = 'loaded'
LOADING_CLASS = 'loading'


PhotoView = BaseView.extend
	className: 'photo'
	template: require('./photo-view.hbs')

	initialize: (options) ->
		@data = _.extend({}, options)
		@isLoaded = false
		@_preloadPromise = null

	render: (options) ->
		BaseView.prototype.render.call(@)

	preloadImage: ->
		if @_preloadPromise? then return Promise.resolve(@_preloadPromise)
		if not @data.url? then return Promise.reject()

		@_preloadPromise = LoadUtils.loadImage(@data.url).then (img) =>
			@isLoaded = true
			return img

		return @_preloadPromise

	loadImage: ->
		if not @data.url? then return Promise.reject()

		el = @el # So we don't have to use @ in a bunch of places.
		el.classList.remove(LOADED_CLASS)
		el.classList.add(LOADING_CLASS)

		@preloadImage().then (img) =>
			titleEl = el.querySelector('.title')
			imgEl = el.querySelector('.img')
			if imgEl?
				#imgContainerEl.insertBefore(img, titleEl)
				imgEl.style.backgroundImage = "url('#{@data.url}')"

			el.classList.remove(LOADING_CLASS)
			el.classList.add(LOADED_CLASS)
			@isLoaded = true

	show: (noTransitions=false) ->
		if noTransitions
			@el.classList.add('no-transitions')

		@el.classList.add('show')
		@el.classList.remove('hide')
		@el.classList.remove('no-transitions')

		@loadImage()

	hide: (noTransitions=false) ->
		if noTransitions
			@el.classList.add('no-transitions')

		@el.classList.remove('show')
		@el.classList.add('hide')
		@el.classList.remove('no-transitions')


module.exports = PhotoView