class HomeRoutes extends Config
	constructor: ($urlRouterProvider, $stateProvider) ->
		$stateProvider.state 'home',
  			url: "/home"
  			templateUrl: "home/home.html"

  		$urlRouterProvider.otherwise("/home")