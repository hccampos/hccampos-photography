_ = require('lodash')
Promise = require('promiscuous')

isDOMReady = false

waitForDOM = ->
	if promise then return promise

	promise = new Promise (resolve, reject) ->
		onReady = ->
			if not isDOMReady
				isDOMReady = true
				resolve()

		# Mozilla, Opera and webkit nightlies currently support this event.
		if document.addEventListener
			onDOMContentLoaded = ->
				document.removeEventListener('DOMContentLoaded', onDOMContentLoaded)
				onReady()

			document.addEventListener('DOMContentLoaded', onDOMContentLoaded, false)

		# If IE event model is used.
		else if document.attachEvent
			onReadyStateChange = ->
				if document.readyState == 'complete'
					document.detachEvent('onreadystatechange', onReadyStateChange)
					onReady()

			# Ensure firing before onload, maybe late but safe also for iframes.
			document.attachEvent('onreadystatechange', onReadyStateChange)

			# If IE and not an iframe continually check to see if the document
			# is ready.
			if document.documentElement.doScroll && window == window.top
				check = ->
					if isDOMReady then return

					try
						# If IE is used, use the trick by Diego Perini
						# http://javascript.nwbox.com/IEContentLoaded/
						document.documentElement.doScroll('left')
					catch error
						setTimeout(check, 0)
						return

					onReady()

				return check()

		# A fallback to window.onload, that will always work.
		window.addEventListener('load', onReady)

	return promise


closest = (el, predicate) ->
		while (el)
			if predicate(el) then return el
			el = el.parentNode

		return null


closestByTag = (el, _tag) ->
	tag = _tag.toUpperCase()

	@closest el, (el) ->
		return el.nodeName == tag


closestBySelector = (el, selector) ->
	@closest el, (el) ->
		return el.querySelector(selector)?


#-------------------------------------------------------------------------------

module.exports = {
	waitForDOM
	closest
	closestByTag
	closestBySelector
}