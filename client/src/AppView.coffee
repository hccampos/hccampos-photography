BaseView = require('./BaseView')
Router = require('./Router')

AppView = BaseView.extend
	el: document.body
	template: require('./main.hbs')

	_transitionPromise: null

	initialize: (options) ->
		@router = new Router(app: @)

	render: ->
		@el.innerHTML = @template()
		@viewEl = @el.querySelector('.view')

		return @

	goto: (view) ->
		if @_transitionPromise?
			# If we are transitioning, let's wait for the transition to complete
			# and then do the new transition.
			return @_transitionPromise.then =>
				@goto(view)

		previous = @currentPage ? null
		next = view

		transitionNextIn = =>
			next.render(page: true)
			@viewEl.appendChild(next.el)
			@currentPage = next
			next.transitionIn()

		if previous?
			@_transitionPromise = previous.transitionOut()
			.then =>
				previous.remove()
				transitionNextIn()
		else
			@_transitionPromise = transitionNextIn()

		@_transitionPromise = @_transitionPromise.then =>
			@_transitionPromise = null


module.exports = AppView