app = angular.module 'app', ['ngResource', '$strap.directives']

app.config ($routeProvider, $locationProvider) ->
    $routeProvider
    .when('/',
        {
            templateUrl : "/partials/index.html",
            controller : "AppCtrl"
        }
    )
    .when('/view/synch',
        {
            templateUrl : "/partials/synch.html",
            controller : "ArticleSynchController"
        }
    )
    .otherwise redirectTo : '/'
    $locationProvider.html5Mode true
    return

app.service("PocketOAuthService", ($resource) ->
    resources = {
        "isAuthorized" : $resource '/api/isAuthorized'
    }

    this.isAuthorized = () ->
        return resources.isAuthorized.get()
)

app.controller "AppCtrl", ($scope) ->

app.controller "ArticleSynchController", ($scope, PocketOAuthService, $rootElement) ->
    $scope.isAuthorized = PocketOAuthService.isAuthorized()

    $scope.disableRouting = () -> $rootElement.off "click"
    $scope.enableRouting = () -> $rootElement.on "click"
