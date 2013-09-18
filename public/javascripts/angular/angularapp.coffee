app = angular.module 'app', ['ngResource', 'ui.route']

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

app.service("DatabaseService", ($resource) ->
    resources = {
        "getCounts" : $resource '/api/getCounts'
        "getArticlesByUrl" : $resource '/api/getArticlesByUrl'
    }

    this.getCounts = (queryParams) ->
        return resources.getCounts.get(queryParams)

    this.getArticlesByUrl =  (queryParams) ->
        return resources.getArticlesByUrl.get(queryParams)
)

app.controller "AppCtrl", ($scope, DatabaseService) ->
    $scope.allCount = DatabaseService.getCounts {"status" : "all"}
    $scope.unreadCount = DatabaseService.getCounts {"status" : "unarchived"}
    $scope.articlesByUrl = DatabaseService.getArticlesByUrl {"status" : "unarchived"}
    $scope.articlesByUrlSelector = "unarchived"
    $scope.updateArticleUrlCount = () ->
        $scope.articlesByUrl = DatabaseService.getArticlesByUrl {"status" : $scope.articlesByUrlSelector}
        return
    return

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
    return

    

