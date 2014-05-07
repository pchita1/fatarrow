APP_NAME = 'app'

BOWER_COMPONENTS =
	'ionic': '1.0.0-beta.3':
		scripts: 'release/js/ionic.bundle.min.js'
		styles: 'release/css/ionic.min.css'

SCRIPTS = [
	'**/ionic.bundle.min.js'
	'app/app.js'
	'**/*.js'
]

STYLES = [
	'**/bootstrap.min.css'
	'**/bootstrap-theme.min.css'
	'**/*.css'
]

module.exports = {APP_NAME, BOWER_COMPONENTS, SCRIPTS, STYLES}