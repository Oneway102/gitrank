
'use strict';

angular.module('rankApp', ['ngRoute'])
  .config ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/rank.html',
        controller: 'RankCtrl'
      .when '/rank/:lang',
        templateUrl: 'views/rank.html',
        controller: 'RankCtrl'
      .when '/popular',
        templateUrl: 'views/rank.html',
        controller: 'RankCtrl'
      .when '/interesting',
        templateUrl: 'views/coming.html',
        controller: 'ComingCtrl'
      .when '/new',
        templateUrl: 'views/coming.html',
        controller: 'ComingCtrl'
      .when '/info/:name',
        templateUrl: 'views/detail.html',
        controller: 'DetailCtrl'
    $locationProvider.html5Mode true

