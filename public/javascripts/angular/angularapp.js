'use strict';

var app = angular.module('app', ['ngResource', 'ui.route']);

app.config(function($routeProvider, $locationProvider) {
  $routeProvider.when('/', {
    templateUrl: "/partials/index.html",
    controller: "AppCtrl"
  }).when('/view/synch', {
    templateUrl: "/partials/synch.html",
    controller: "ArticleSynchController"
  }).otherwise({
    redirectTo: '/'
  });
  $locationProvider.html5Mode(true);
});

app.service("PocketOAuthService", function($resource) {
  var resources = {
    "isAuthorized": $resource('/api/isAuthorized'),
    "updateArticles": $resource('/api/itemsSince')
  };

  this.isAuthorized = function() {
    return resources.isAuthorized.get();
  };

  this.updateArticles = function() {
    return resources.updateArticles.get();
  };
});

app.service("DatabaseService", function($resource) {
  var resources = {
    "getCounts": $resource('/api/getCounts'),
    "getArticlesByUrl": $resource('/api/getArticlesByUrl')
  };

  this.getCounts = function(queryParams) {
    return resources.getCounts.get(queryParams);
  };

  this.getArticlesByUrl = function(queryParams) {
    return resources.getArticlesByUrl.get(queryParams);
  };
});

app.controller("AppCtrl", function($scope, DatabaseService) {
  $scope.allCount = DatabaseService.getCounts({
    "status": "all"
  });

  $scope.unreadCount = DatabaseService.getCounts({
    "status": "unarchived"
  });

  $scope.articlesByUrl = DatabaseService.getArticlesByUrl({
    "status": "unarchived"
  });

  $scope.articlesByUrlSelector = "unarchived";

  $scope.updateArticleUrlCount = function() {
    $scope.articlesByUrl = DatabaseService.getArticlesByUrl({
      "status": $scope.articlesByUrlSelector
    });
  };
});

app.controller("ArticleSynchController", function($scope, PocketOAuthService, $rootElement) {
  $scope.isAuthorized = PocketOAuthService.isAuthorized();

  $scope.disableRouting = function() {
    $rootElement.off("click");
  };

  $scope.enableRouting = function() {
    $rootElement.on("click");
  };

  $scope.updateStatusText = "";

  $scope.updateArticle = function() {
    $scope.updateStatusText = "Update in progress...";
    $scope.updateStatus = PocketOAuthService.updateArticles();
  };

  $scope.$watch('updateStatus', (function(newVal, oldVal) {
    if ((newVal != null) && (newVal.status != null)) {
      if (newVal.status === "success") {
        $scope.updateStatusText = "Finished Update";
      } else {
        $scope.updateStatusText = newVal.error;
      }
    }
  }), true);
});