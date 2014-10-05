_ = require('lodash')
BaseView = require('../BaseView')
AlbumView = require('./AlbumView')

HomeView = BaseView.extend
	className: 'home-view'
	template: require('./home-view.hbs')
	data: {}

	initialize: (options) ->
		_.extend(@data, options)

	render: (options) ->
		BaseView.prototype.render.call(@, options)

		listEl = @el.querySelector('.album-list')

		_.forEach @data.albums, (album) ->
			albumView = new AlbumView(album)
			albumView.render()
			listEl.appendChild(albumView.el)

		return @


module.exports = HomeView