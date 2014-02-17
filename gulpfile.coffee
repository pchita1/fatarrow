bowerDirectory = './bower_components/'
changelog = './CHANGELOG.md'
componentsDirectory = "#{bowerDirectory}flattened_components/"
distDirectory = './dist/'
srcDirectory = './src/'
tempDirectory = './.temp/'

normalizeComponentMap =
	'.css': 'styles/'
	'.eot': 'fonts/'
	'.js': 'scripts/libs/'
	'.less': 'styles/'
	'.svg': 'fonts/'
	'.ttf': 'fonts/'
	'.woff': 'fonts/'

bower = require 'gulp-bower'
bowerFiles = require 'gulp-bower-files'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
conventionalChangelog = require 'conventional-changelog'
fs = require 'fs'
gulp = require 'gulp'
gutil = require 'gulp-util'
jade = require 'gulp-jade'
less = require 'gulp-less'
markdown = require 'gulp-markdown'
ngClassify = require 'gulp-ng-classify'
path = require 'path'
pkg = require './package.json'

gulp.task 'bower', ->
	bower()

gulp.task 'build', ['scripts', 'styles', 'views'], ->
	gulp
		.src '**', cwd: tempDirectory
		.pipe gulp.dest distDirectory

gulp.task 'changelog', ->
	options =
		repository: pkg.repository.url
		version: pkg.version
		file: changelog
		log: gutil.log

	conventionalChangelog options, (err, log) ->
		fs.writeFile changelog, log

gulp.task 'clean', ['clean:working'], ->
	gulp
		.src bowerDirectory
		.pipe clean()

gulp.task 'clean:working', ->
	gulp
		.src [componentsDirectory, tempDirectory, distDirectory]
		.pipe clean()

gulp.task 'coffee', ['coffeelint', 'ngClassify'], ->
	options =
		sourceMap: true

	gulp
		.src '**/*.coffee', cwd: tempDirectory
		.pipe coffee options
		.pipe gulp.dest tempDirectory

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
		.src '**/*.coffee', cwd: srcDirectory
		.pipe coffeelint options
		.pipe coffeelint.reporter()

gulp.task 'components', ['bower', 'clean:working'], ->
	bowerFiles()
		.on 'data', (data) ->
			fileName = path.basename data.path
			ext = path.extname fileName
			subPath = normalizeComponentMap[ext]
			p = path.join data.base, subPath, fileName
			data.path = p

			data
		.pipe gulp.dest componentsDirectory

gulp.task 'copy:temp', ['clean:working', 'components'], ->
	gulp
		.src ["#{srcDirectory}**", "#{componentsDirectory}**"]
		.pipe gulp.dest tempDirectory

gulp.task 'default', ['build']

gulp.task 'jade', ['copy:temp'], ->
	options =
		pretty: true

	gulp
		.src '**/*.jade', cwd: tempDirectory
		.pipe jade options
		.pipe gulp.dest tempDirectory

gulp.task 'less', ['copy:temp'], ->
	gulp
		.src 'styles/styles.less', cwd: tempDirectory
		.pipe less()
		.pipe gulp.dest 'styles/', cwd: tempDirectory

gulp.task 'markdown', ['copy:temp'], ->
	gulp
		.src '**/*.{md,markdown}', cwd: tempDirectory
		.pipe markdown()
		.pipe gulp.dest tempDirectory

gulp.task 'ngClassify', ['copy:temp'], ->
	gulp
		.src '**/*.coffee', cwd: tempDirectory
		.pipe ngClassify()
		.pipe gulp.dest tempDirectory

gulp.task 'scripts', ['coffee']

gulp.task 'styles', ['less']

gulp.task 'views', ['jade', 'markdown']
































# es = require 'event-stream'
# filter = require 'gulp-filter'






# minifyHtml = require 'gulp-minify-html'



# template = require 'gulp-template'

# scripts = [
# 	'scripts/libs/angular.min.js'
# 	'scripts/libs/angular-mocks.js'
# 	'scripts/libs/angular-animate.min.js'
# 	'scripts/libs/angular-route.min.js'
# 	'!scripts/libs/html5shiv-printshiv.js'
# 	'!scripts/libs/json3.min.js'
# 	'**/*.js'
# ]

# styles = [
# 	'styles/styles.css'
# ]

# fonts = ['**/*.{eot,svg,ttf,woff}']
# assets = [].concat(scripts).concat(styles).concat(fonts)




# # inject = require 'gulp-inject'

# # gulp.task 'inject', ->
# # 	gulp
# # 		.src assets, {cwd: tempDirectory, read: false}
# # 		.pipe inject './index.html', ignorePath: path.resolve tempDirectory
# # 		.pipe gulp.dest tempDirectory






# # bust = require 'gulp-buster'
# # rename = require 'gulp-rename'

# gulp.task 'bust', ->
# 	bust.config
# 		length: 10

# 	gulp
# 		.src assets, cwd: tempDirectory
# 		.pipe bust 'busters.json'
# 		.pipe gulp.dest '.'

# gulp.task 'bustit', ['bust'], ->
# 	busters = require './busters.json'

# 	gulp
# 		.src assets, cwd: tempDirectory
# 		.pipe rename (filePath) ->
# 			originalPath = path.join filePath.dirname, filePath.basename + filePath.extname
# 			hash = busters[originalPath]
# 			filePath.basename += ".#{hash}"

# 			filePath
# 		.pipe gulp.dest tempDirectory








# PluginError = gutil.PluginError

# includify = (fileName, opt = {}) ->
# 	if !fileName
# 		throw new PluginError 'includify', 'Missing filename option'

# 	scriptsToInclude = []
# 	stylesToInclude = []

# 	bufferContents = (file) ->
# 		return if file.isNull()

# 		return if file.isStream()
# 			@emit 'error', new PluginError 'includify', 'Streaming not supported'

# 		ext = path.extname file.path
# 		p = path.resolve '/', path.relative file.cwd, file.path

# 		return if ext is '.js'
# 			scriptsToInclude.push p

# 		return if ext is '.css'
# 			stylesToInclude.push p

# 	endStream = ->
# 		return if scriptsToInclude.length is 0 or stylesToInclude.length is 0
# 			@emit 'end'

# 		@emit 'data', {scripts: scriptsToInclude, styles: stylesToInclude}
# 		@emit 'end'

# 	es.through bufferContents, endStream



# gulp.task 'template', ['copy:temp', 'scripts', 'styles'], ->
# 	files = []
# 		.concat scripts
# 		.concat styles

# 	gulp
# 		.src files, cwd: './.temp/'
# 		.pipe includify './.temp/index.html'
# 		.on 'data', (data) ->
# 			gulp
# 				.src './.temp/index.html'
# 				.pipe template data
# 				.pipe gulp.dest './.temp/'









































# gulp.task 'minifyHtml', ['jade', 'markdown'], ->
# 	options =
# 		quotes: true

# 	gulp
# 		.src './.temp/**/*.html'
# 		.pipe minifyHtml options
# 		.pipe gulp.dest './.temp/'