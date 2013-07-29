app = angular.module 'app', ['ngResource']

app.config ($routeProvider, $locationProvider) ->
    $routeProvider
    .when('/',
        {
            templateUrl : "partials/index.html",
            controller : "AppCtrl"
        }
    )
    .otherwise redirectTo : '/'
    $locationProvider.html5Mode true
    return

app.service "PocketService", ($resource) ->

    return

app.controller "AppCtrl", ($scope) ->