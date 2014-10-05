require('coffee-script')
gulp = require('gulp')

path = require('path')
browserify = require('gulp-browserify')
coffee = require('gulp-coffee')
cson = require('gulp-cson')
concat = require('gulp-concat')
del = require('del')
gulpif = require('gulp-if')
htmlmin = require('gulp-htmlmin')
plumber = require('gulp-plumber')
rename = require('gulp-rename')
sass = require('gulp-sass')
uglify = require('gulp-uglify')

projectName = require('./package.json').name

config =
	production: false

paths =
	html: 'client/src/**/*.html'
	templates: 'client/src/**/*.hbs'
	scripts:
		main: 'client/src/main.coffee'
		all: 'client/src/**/*.coffee'
	styles:
		main: 'client/src/main.scss'
		all: 'client/src/**/*.scss'
	assets: 'client/assets/**/*'
	data: 'client/data/**/*.cson'


safe = (stream) ->
	stream.on 'error', (error) ->
		console.log(error)
		stream.end()
		this.emit('end')
	return stream


gulp.task 'config:prod', ->
	config.production = true


gulp.task 'config:dev', ->
	config.production = false


gulp.task 'clean', (cb) ->
	del(['build'], cb)


gulp.task 'html', ['clean'], ->
	gulp.src(paths.html)
		.pipe(plumber())
		.pipe(htmlmin(collapseWhitespace: true))
		.pipe(gulp.dest('build'))


gulp.task 'scripts', ['clean'], ->
	bundle = ->
		browserify
			transform: ['hbsfy', 'coffeeify']
			extensions: ['.coffee']
			debug: !config.production
		.on 'prebundle', (bundler) ->
			bundler.require('lodash', {expose: 'underscore'})
			bundler.exclude('jquery')

	gulp.src(paths.scripts.main, {read: false})
		.pipe(plumber())
		.pipe(safe(bundle()))
		.pipe(concat("#{projectName}.js"))
		.pipe(gulpif(config.production, safe(uglify())))
		.pipe(gulp.dest('build'))


gulp.task 'styles', ['clean'], ->
	outputStyle = if config.production then 'compressed' else 'nested'

	gulp.src(paths.styles.main)
		.pipe(safe(sass({
			outputStyle: outputStyle
			includePaths: ['./client/src/common/styles']
		})))
		.pipe(rename("#{projectName}.css"))
		.pipe(gulp.dest('build'))


gulp.task 'assets', ['clean'], ->
	gulp.src(paths.assets).pipe(gulp.dest('build'))


gulp.task 'data', ['clean'], ->
	gulp.src(paths.data)
		.pipe(plumber())
		.pipe(safe(cson()))
		.pipe(gulp.dest('build/data'))


gulp.task 'watch', ->
	gulp.watch(paths.html, ['build'])
	gulp.watch(paths.templates, ['build'])
	gulp.watch(paths.scripts.all, ['build'])
	gulp.watch(paths.styles.all, ['build'])
	gulp.watch(paths.assets, ['build'])
	gulp.watch(paths.data, ['build'])


gulp.task('build', [
	'clean'
	'html'
	'scripts'
	'styles'
	'data'
	'assets'
])

gulp.task('default', ['config:dev', 'watch', 'build'])
gulp.task('production', ['config:prod', 'build'])
gulp.task('heroku:production', ['production'])