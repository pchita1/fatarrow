### config begin ###
APP_NAME = 'app'

BOWER_COMPONENTS =
	'angular'              : '1.3.0-beta.5'
	'angular-animate'      : '1.3.0-beta.5'
	'angular-mocks'        : '1.3.0-beta.5'
	'angular-route'        : '1.3.0-beta.5'
	'bootstrap'            : '3.1.1'
	'google-code-prettify' : '1.0.1'

BOWER_COMPONENTS_FONTS = [
	'bootstrap/dist/fonts/**/*.{eot,svg,ttf,woff}'
]

BOWER_COMPONENTS_SCRIPTS = [
	'angular/angular.min.js'
	'angular-animate/angular-animate.min.js'
	'angular-mocks/angular-mocks.js'
	'angular-route/angular-route.min.js'
	'google-code-prettify/src/prettify.js'
]

BOWER_COMPONENTS_STYLES = [
	'bootstrap/dist/css/*.min.css'
	'google-code-prettify/styles/sons-of-obsidian.css'
]

VENDOR_DIRECTORY         = 'vendor/'
VENDOR_FONTS_DIRECTORY   = "#{VENDOR_DIRECTORY}fonts/"
VENDOR_SCRIPTS_DIRECTORY = "#{VENDOR_DIRECTORY}scripts/"
VENDOR_STYLES_DIRECTORY  = "#{VENDOR_DIRECTORY}styles/"

SCRIPTS = [
	"#{VENDOR_SCRIPTS_DIRECTORY}angular.min.js"
	"#{VENDOR_SCRIPTS_DIRECTORY}angular-mocks.js"
	"#{VENDOR_SCRIPTS_DIRECTORY}angular-animate.min.js"
	"#{VENDOR_SCRIPTS_DIRECTORY}angular-route.min.js"
	'app/App.js'
	'**/*.js'
]

STYLES = [
	"#{VENDOR_STYLES_DIRECTORY}bootstrap.min.css"
	"#{VENDOR_STYLES_DIRECTORY}bootstrap-theme.min.css"
	'**/*.css'
]

BOWER_DIRECTORY      = './.components/'
CHANGELOG_FILE       = './CHANGELOG.md'
COMPONENTS_DIRECTORY = "#{BOWER_DIRECTORY}flattened_components/"
DEV_PORT             = 8181
DIST_DIRECTORY       = './dist/'
DOCS_DIRECTORY       = './docs/'
SCRIPTS_MIN_FILE     = 'scripts.min.js'
SRC_DIRECTORY        = './src/'
STYLES_MIN_FILE      = 'styles.min.css'
TEMP_DIRECTORY       = './.temp/'
### config end ###

bower                 = require 'bower'
buster                = require 'gulp-buster'
clean                 = require 'gulp-clean'
coffee                = require 'gulp-coffee'
coffeelint            = require 'gulp-coffeelint'
concat                = require 'gulp-concat'
connect               = require 'gulp-connect'
conventionalChangelog = require 'conventional-changelog'
es                    = require 'event-stream'
flatten               = require 'gulp-flatten'
fs                    = require 'fs'
gulp                  = require 'gulp'
gutil                 = require 'gulp-util'
jade                  = require 'gulp-jade'
less                  = require 'gulp-less'
markdown              = require 'gulp-markdown'
minifyCss             = require 'gulp-minify-css'
minifyHtml            = require 'gulp-minify-html'
ngClassify            = require 'gulp-ng-classify'
open                  = require 'gulp-open'
path                  = require 'path'
pkg                   = require './package.json'
q                     = require 'q'
rename                = require 'gulp-rename'
template              = require 'gulp-template'
templateCache         = require 'gulp-angular-templatecache'
uglify                = require 'gulp-uglify'
yuidoc                = require 'gulp-yuidoc'

gulp.task 'bower', ->
	deferred = q.defer()
	components = []

	for component, version of BOWER_COMPONENTS
		components.push "#{component}##{version}"

	bower
		.commands
		.install components, {}, {directory: BOWER_DIRECTORY}
		.on 'end', (results) ->
			deferred.resolve results

	deferred.promise

gulp.task 'build', ['scripts', 'styles', 'views', 'spa'], ->
	gulp
		.src '**', cwd: TEMP_DIRECTORY
		.pipe gulp.dest DIST_DIRECTORY

gulp.task 'changelog', ->
	options =
		repository: pkg.repository.url
		version: pkg.version
		file: CHANGELOG_FILE
		log: gutil.log

	conventionalChangelog options, (err, log) ->
		fs.writeFile CHANGELOG_FILE, log

gulp.task 'clean', ['clean:working'], ->
	gulp
		.src BOWER_DIRECTORY
		.pipe clean()

gulp.task 'clean:working', ->
	gulp
		.src [COMPONENTS_DIRECTORY, TEMP_DIRECTORY, DIST_DIRECTORY, DOCS_DIRECTORY]
		.pipe clean()

gulp.task 'coffee', ['coffeelint', 'ngClassify'], ->
	options =
		sourceMap: true

	gulp
		.src '**/*.coffee', cwd: TEMP_DIRECTORY
		.pipe coffee options
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'coffeelint', ->
	options =
		arrow_spacing:
			level: 'error'
		indentation:
			value: 1
		max_line_length:
			level: 'ignore'
		no_tabs:
			level: 'ignore'

	gulp
		.src [
			'**/*.coffee'
			'!app/app.coffee'
		], cwd: SRC_DIRECTORY
		.pipe coffeelint options
		.pipe coffeelint.reporter()

gulp.task 'copy:temp', ['clean:working', 'flatten'], ->
	gulp
		.src [
			"#{SRC_DIRECTORY}**"
			"#{COMPONENTS_DIRECTORY}**"
		]
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'default', ['open', 'watch', 'build']

gulp.task 'docs', ['yuidoc']

gulp.task 'flatten', ['flatten:fonts', 'flatten:scripts', 'flatten:styles']

gulp.task 'flatten:fonts', ['bower', 'clean:working'], ->
	gulp
		.src BOWER_COMPONENTS_FONTS, cwd: BOWER_DIRECTORY
		.pipe flatten()
		.pipe gulp.dest "#{COMPONENTS_DIRECTORY}#{VENDOR_FONTS_DIRECTORY}"

gulp.task 'flatten:scripts', ['bower', 'clean:working'], ->
	gulp
		.src BOWER_COMPONENTS_SCRIPTS, cwd: BOWER_DIRECTORY
		.pipe flatten()
		.pipe gulp.dest "#{COMPONENTS_DIRECTORY}#{VENDOR_SCRIPTS_DIRECTORY}"

gulp.task 'flatten:styles', ['bower', 'clean:working'], ->
	gulp
		.src BOWER_COMPONENTS_STYLES, cwd: BOWER_DIRECTORY
		.pipe flatten()
		.pipe gulp.dest "#{COMPONENTS_DIRECTORY}#{VENDOR_STYLES_DIRECTORY}"

gulp.task 'jade', ['copy:temp'], ->
	options =
		pretty: true

	gulp
		.src '**/*.jade', cwd: TEMP_DIRECTORY
		.pipe jade options
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'less', ['copy:temp'], ->
	options =
		sourceMap: true
		sourceMapBasepath: path.resolve path.join TEMP_DIRECTORY, 'styles'

	gulp
		.src 'styles/styles.less', cwd: TEMP_DIRECTORY
		.pipe less options
		.pipe gulp.dest 'styles/', cwd: TEMP_DIRECTORY

gulp.task 'markdown', ['copy:temp'], ->
	gulp
		.src '**/*.{md,markdown}', cwd: TEMP_DIRECTORY
		.pipe markdown()
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'ngClassify', ['copy:temp'], ->
	options =
		appName: APP_NAME or 'app'
		data:
			environment: 'dev'

	gulp
		.src '**/*.coffee', cwd: TEMP_DIRECTORY
		.pipe ngClassify options
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'open', ['serve'], ->
	options =
		url: "http://localhost:#{DEV_PORT}"

	gulp
		.src 'index.html', cwd: DIST_DIRECTORY
		.pipe open '', options

gulp.task 'reload', ['build'], ->
	gulp
		.src 'index.html', cwd: DIST_DIRECTORY
		.pipe connect.reload()

gulp.task 'scripts', ['coffee']

gulp.task 'serve', ['build'], ->
	connect.server
		livereload: true
		port: DEV_PORT
		root: DIST_DIRECTORY

gulp.task 'spa', ['scripts', 'styles', 'views'], ->
	unixifyPath = (p) ->
			regex = /\\/g
			p.replace regex, '/'

	includify = ->
		scripts = []
		styles = []

		bufferContents = (file) ->
			return if file.isNull()

			ext = path.extname file.path
			p = unixifyPath(path.join('/', path.relative(file.cwd, file.path)))

			return if ext is '.js'
				scripts.push p

			return if ext is '.css'
				styles.push p

		endStream = ->
			payload = {scripts, styles}
			@emit 'data', payload
			@emit 'end', payload

		es.through bufferContents, endStream

	getIncludes = ->
		deferred = q.defer()

		files = []
			.concat SCRIPTS
			.concat STYLES

		gulp
			.src files, cwd: TEMP_DIRECTORY
			.pipe includify()
			.on 'end', (data) ->
				deferred.resolve data

		deferred.promise

	processTemplate = (files) ->
		deferred = q.defer()

		data =
			appName: APP_NAME
			scripts: files.scripts
			styles: files.styles

		gulp
			.src 'index.html', cwd: TEMP_DIRECTORY
			.pipe template data
			.pipe gulp.dest TEMP_DIRECTORY
			.on 'end', ->
				deferred.resolve()

		deferred.promise

	getIncludes()
		.then processTemplate

gulp.task 'styles', ['less']

gulp.task 'views', ['jade', 'markdown']

gulp.task 'watch', ['build'], ->
	gulp
		.watch "#{SRC_DIRECTORY}**/*.{coffee,css,html,jade,less,markdown,md}", ['reload']

gulp.task 'yuidoc', ->
	options =
		syntaxtype: 'coffee'

	gulp
		.src '**/*.coffee', cwd: SRC_DIRECTORY
		.pipe yuidoc options
		.pipe gulp.dest DOCS_DIRECTORY


### prod ###
gulp.task 'minify', ['minify:scripts', 'minify:styles', 'minify:views', 'minify:spa']

gulp.task 'minify:scripts', ['templateCache'], ->
	gulp
		.src SCRIPTS, cwd: TEMP_DIRECTORY
		.pipe concat SCRIPTS_MIN_FILE
		.pipe uglify()
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'minify:styles', ->
	options =
		keepSpecialComments: 0

	gulp
		.src STYLES, cwd: TEMP_DIRECTORY
		.pipe concat STYLES_MIN_FILE
		.pipe minifyCss options
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'minify:spa', ->
	options =
		empty: true
		quotes: true

	gulp
		.src 'index.html', cwd: TEMP_DIRECTORY
		.pipe minifyHtml options
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'minify:views', ->
	options =
		empty: true
		quotes: true

	gulp
		.src ['**/*.html', '!index.html'], cwd: TEMP_DIRECTORY
		.pipe minifyHtml options
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'templateCache', ['minify:views'], ->
	options =
		module: APP_NAME
		root: '/'

	gulp
		.src ['**/*.html', '!index.html'], cwd: TEMP_DIRECTORY
		.pipe templateCache options
		.pipe gulp.dest "#{TEMP_DIRECTORY}scripts/"

gulp.task 'buster', ->
	options =
		length: 10

	buster.config options

	gulp
		.src '**/*.{css,js}', cwd: TEMP_DIRECTORY
		.pipe buster()
		.pipe gulp.dest TEMP_DIRECTORY

gulp.task 'hashify', ['buster'], ->
	busters = require "#{TEMP_DIRECTORY}busters.json"

	renamer = (file) ->
		originalFile = path.join file.dirname, file.basename + file.extname

		# gulp
		# 	.src originalFile, cwd: TEMP_DIRECTORY
		# 	.pipe clean()


		hash = busters[originalFile]
		file.basename += '.' + hash

		file

	gulp
		.src '**/*.{css,js}', cwd: TEMP_DIRECTORY
		.pipe rename renamer
		.pipe gulp.dest TEMP_DIRECTORY