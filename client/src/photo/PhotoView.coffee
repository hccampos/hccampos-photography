BaseView = require('../BaseView')


PhotoView = BaseView.extend
	className: 'photo-view'
	template: require('./photo-view.hbs')


module.exports = PhotoView