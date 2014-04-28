'use strict';

angular.module('rankApp')
  # $route is needed here to as our ng-view in warpped by ng-include and 
  # we need to ensure $route is ready beforehand.
  .controller 'AppCtrl', ($rootScope, $scope, $route, $http) ->
    $scope.loading = true
    $scope.languages = []
    $scope.rank = {}
    $scope.langFilter = "JavaScript"
    retrieveRank = () ->
      $scope.loading = true
      $http.get("/api/rank?language=#{$scope.langFilter}")
        .success (data) ->
          $scope.rank = data
          $scope.loading = false
        .error () ->
          $scope.loading = false
    retrieveRank()
    $http.get("/api/languages")
      .success (data) ->
        $scope.languages = data
    getTagValue = ($event) ->
      realTarget = $event.target
      if $event.target.tagName is "LI"
        realTarget = $event.target.children[0]
      return realTarget.innerHTML
    updateFocus = ($event) ->
      realTarget = $event.target
      if $event.target.tagName is "LI"
        realTarget = $event.target.children[0]
      selectedTag = $("li.selectable.tag-b.selected")
      if selectedTag.length <= 0
        return
      return if realTarget.innerHTML is $("li.selectable.tag-b.selected")

    $scope.getScore = (person) ->
      return 0 if not person.contrib[$scope.langFilter]
      score = 0
      languages = person.contrib[$scope.langFilter]
      for key, value of person.contrib[$scope.langFilter]
        for k, v of value
          score += v
      return score
    $scope.setLanguage = ($event, lang) ->
      $scope.langFilter = getTagValue($event)
      retrieveRank()

    $scope.getName = (person) ->
      return person.info.name if person.info.name and person.info.name.length > 0
      return person.info.login

  .controller 'RankCtrl', ($rootScope, $scope, $route, $http, $location) ->
    $scope.viewPerson = (person) ->
      $rootScope.selectedPerson = person
      b = "/info/#{$scope.langFilter}/#{person.info.login}"
      $location.path "/info/#{$scope.langFilter}/#{person.info.login}"
    return

  .controller 'DetailCtrl', ($rootScope, $scope, $route, $http, $routeParams) ->
    $scope.person = $rootScope.selectedPerson
    # We may need to retrieve data from server.
    if not $scope.person
      $http.get("/api/detail?language=#{$routeParams.lang}&loging=#{$routeParams.name}")
        .success (data) ->
          $scope.person = data
