BaseView = require('../BaseView')


AlbumView = BaseView.extend
	className: 'album-view'
	template: require('./album-view.hbs')


module.exports = AlbumView