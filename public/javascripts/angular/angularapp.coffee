app = angular.module 'app', ['ngResource', '$strap.directives']

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

app.controller "AppCtrl", ($scope) ->