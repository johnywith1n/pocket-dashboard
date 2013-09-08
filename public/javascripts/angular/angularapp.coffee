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
        "updateArticles" : $resource '/api/itemsSince'
    }

    this.isAuthorized = () ->
        return resources.isAuthorized.get()

    this.updateArticles = () ->
        return resources.updateArticles.get()
)

app.controller "AppCtrl", ($scope) ->

app.controller "ArticleSynchController", ($scope, PocketOAuthService, $rootElement) ->
    $scope.isAuthorized = PocketOAuthService.isAuthorized()

    $scope.disableRouting = () -> $rootElement.off "click"
    $scope.enableRouting = () -> $rootElement.on "click"

    $scope.updateStatusText = ""

    $scope.updateArticle = () ->
        $scope.updateStatusText = "Update in progress..."
        $scope.updateStatus = PocketOAuthService.updateArticles()

    $scope.$watch 'updateStatus', ((newVal, oldVal) ->
        if newVal? and newVal.status?
            if newVal.status is "success"
                $scope.updateStatusText = "Finished Update"
            else
                $scope.updateStatusText = newVal.error
    ), true


    

