class TourRoutes extends Config
	constructor: ($urlRouterProvider, $stateProvider) ->
		$stateProvider.state "tour",
  			url: "/tour"
  			templateUrl: "tour/tour.html"