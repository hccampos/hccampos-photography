require('./common/shims')
require('./partials')

DOMUtils = require('./common/DOMUtils')
Backbone = require('exoskeleton')
AppView = require('./AppView')

DOMUtils.waitForDOM()
.then ->
	app = new AppView()
	app.render()
	Backbone.history.start(pushState: true)

	# Make sure all clicks on links use the Backbone router.
	document.addEventListener 'click', (event) ->
		target = DOMUtils.closestByTag(event.target, 'a')
		if not target? then return

		href =
			prop: target?.href
			attr: target?.getAttribute?('href')

		root = "#{window.location.protocol}//#{window.location.host}#{Backbone.history.options.root}"

		if href.prop and href.prop.slice(0, root.length) == root
			event.preventDefault()
			Backbone.history.navigate(href.attr, true)
