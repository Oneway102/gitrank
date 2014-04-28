
'use strict';

angular.module('rankApp', ['ngRoute'])
  .config ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/ranks.html',
        templateUrl: 'rank/views/rank.html',
        controller: 'RankCtrl'
      .when '/info/:lang/:name',
        templateUrl: 'rank/views/detail.html',
        controller: 'DetailCtrl'
    $locationProvider.html5Mode true

