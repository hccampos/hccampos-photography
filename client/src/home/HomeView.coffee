_ = require('lodash')
BaseView = require('../BaseView')
AlbumView = require('./album/HomeAlbumView')

HomeView = BaseView.extend
	className: 'home'
	template: require('./home-view.hbs')

	initialize: (options) ->
		@data = _.extend({}, options)

	render: (options) ->
		BaseView.prototype.render.call(@, options)

		listEl = @el.querySelector('.album-list')
		listEl.innerHTML = ''

		for album in @data.albums
			albumView = new AlbumView(album)
			albumView.render()
			listEl.appendChild(albumView.el)

		return @


module.exports = HomeView