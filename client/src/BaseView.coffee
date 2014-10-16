Promise = require('promiscuous')
Backbone = require('exoskeleton')

VISIBLE_CLASS = 'is-visible'
TRANSITION_IN_CLASS = 'transition-in'
TRANSITION_OUT_CLASS = 'transition-out'
TRANSITION_DURATION = 500

BaseView = Backbone.View.extend
	render: (options) ->
		options ?= {}

		if options.page == true
			@el.classList.add('page')

		if @template?
			@el.innerHTML = @template(@data)

		return @

	transitionIn: (callback) ->
		new Promise (resolve, reject) =>
			onTransitionEnd = =>
				@el.classList.remove(TRANSITION_IN_CLASS)
				resolve(@)

			transition = =>
				@el.classList.add(VISIBLE_CLASS)
				@el.classList.add(TRANSITION_IN_CLASS)
				window.setTimeout(onTransitionEnd, TRANSITION_DURATION)

			window.setTimeout(transition, 20)

	transitionOut: ->
		new Promise (resolve, reject) =>
			onTransitionEnd = =>
				@el.classList.remove(TRANSITION_OUT_CLASS)
				resolve(@)

			@el.classList.remove(VISIBLE_CLASS)
			@el.classList.add(TRANSITION_OUT_CLASS)
			window.setTimeout(onTransitionEnd, TRANSITION_DURATION)

module.exports = BaseView