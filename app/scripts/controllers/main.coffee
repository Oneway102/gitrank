'use strict';

API_HOST = "ats.borqs.com"

JSON_CALLBACK3 = (data) ->
  aaa = data

angular.module('rankApp')
  # $route is needed here to as our ng-view in warpped by ng-include and 
  # we need to ensure $route is ready beforehand.
  .controller 'AppCtrl', ($rootScope, $scope, $route, $http, $location) ->
    $scope.currentTab = "popular"
    $scope.loading = true
    $scope.languages = []
    if $scope.languages.length is 0
      $http.get("http://#{API_HOST}/github/languages")
        .success (data) ->
          $scope.languages = data.data
    $rootScope.langFilter = "JavaScript"

    $rootScope.rank = {}
    $rootScope.pageIndex = 0
    $rootScope.loading = false
    $rootScope.paginationInit = false
    initPagination = () ->
      $('#pagination').show()
      $('.pagination').jqPagination({
        max_page: $rootScope.rank?.pages || 1
        paged: (page) ->
          return if page > $rootScope.rank.pages || $rootScope.pageIndex is page - 1
          $rootScope.pageIndex = page - 1
          $rootScope.retrieveRank()
      })
      $rootScope.paginationInit = true
      return
    $rootScope.retrieveRank = (reset) ->
      #return if $rootScope.loading is true
      if reset and $rootScope.paginationInit 
        $('.pagination').jqPagination('destroy')
        $rootScope.paginationInit = false
      $rootScope.loading = true
      language = encodeURIComponent($rootScope.langFilter)
      $http.get("http://#{API_HOST}/github/rank?language=#{language}&page_count=10&page=#{$rootScope.pageIndex}")
        .success (data) ->
          $rootScope.loading = false
          $rootScope.rank = data
          #$rootScope.rank.pages = 1000 if $rootScope.rank.pages > 1000
          initPagination() if not $rootScope.paginationInit
          #if $rootScope.rank.pages isnt $('.pagination').jqPagination('option', 'max_page')
          #  $('.pagination').jqPagination('option', 'max_page', $rootScope.rank.pages)
          $('#pagination').hide() if $rootScope.rank.pages is 0
          return
        .error () ->
          $rootScope.loading = false
          $('#pagination').hide()
          return
    ###
    $scope.goto = (page) ->
      $rootScope.pageIndex = page
      retrieveRank()
    ###
    getTagValue = ($event) ->
      realTarget = $event.target
      if $event.target.tagName is "LI"
        realTarget = $event.target.children[0]
      return realTarget.innerHTML
    $scope.setLanguage = ($event, lang) ->
      $location.path "rank/#{getTagValue($event)}"
    $scope.changeTab = (tab) ->
      $scope.currentTab = tab
      $location.path "/" + tab
      return
    $rootScope.getName = (person) ->
      return "" if not person?.info
      return person.info.name if person.info.name and person.info.name.length > 0
      return person.info.login
    $rootScope.getDesc = (person) ->
      return " " if not person?.info
      return if not person.info.bio?.length then "注册时间: " + person.info.created_at.replace("T", " ").replace("Z", "") else person.info.bio
    $scope.showLanguageTag = () ->
      return $location.$$path.indexOf("info") is 1
    $scope.getTagsCaption = () ->
      return if $location.$$path.indexOf("info") is 1 then "搜一搜" else "编程语言"
    $scope.searchUser = () ->
      id = $("#githubId")[0].value
      return if not id or id.length is 0
      $location.path "/info/#{id}"
    $scope.onKeyPress = ($event) ->
      $scope.searchUser() if $event.which is 13

  .controller 'RankCtrl', ($rootScope, $scope, $route, $http, $location, $routeParams) ->
    $scope.$parent.currentTab = "popular"
    $scope.sectionId = "modules"
    $rootScope.langFilter = $routeParams.lang || "JavaScript"
    $scope.loading = true
    #$scope.rank = {}
    $('#pagination').show()

    retrieveRank = () ->
      $scope.loading = true
      language = encodeURIComponent($rootScope.langFilter)
      $http.get("http://#{API_HOST}/github/rank?language=#{language}&page_count=10")
        .success (data) ->
          $scope.rank = data
          $scope.loading = false
        .error () ->
          $scope.loading = false
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
      return 0 if not person.contrib[$rootScope.langFilter]
      score = 0
      languages = person.contrib[$rootScope.langFilter]
      for key, value of person.contrib[$rootScope.langFilter]
        for k, v of value
          score += v
      return score

    #$scope.getName = $scope.$parent.getName
    $scope.viewPerson = (person) ->
      $location.path "/info/#{person.info.login}"

    $rootScope.pageIndex = 0
    $rootScope.retrieveRank(true)
    return

  .controller 'DetailCtrl', ($rootScope, $scope, $route, $http, $routeParams) ->
    $scope.$parent.currentTab = "popular"
    $scope.sectionId = "moduleInfo"
    $scope.person = {}
    $scope.loginName = $routeParams.name
    $('#pagination').hide()
    formatMonth = (m) ->
      result = if String(m).length is 1 then "0" + String(m) else String(m)

    buildDataMonthly = () ->
      MAX_BARS = 12
      currentMonth = (new Date()).getMonth() + 1
      currentYear = (new Date()).getFullYear()
      myData = []
      month = currentMonth
      for m in [MAX_BARS...0]
        if month > 0
          myData[m-1] = [currentYear + "/" + month, $scope.person.month[String(currentYear)]?[formatMonth(month)] || 0]
        else
          lmonth = month + 12
          myData[m-1] = [String(currentYear-1) + "/" + lmonth, $scope.person.month[String(currentYear-1)]?[formatMonth(lmonth)] || 0]
        month--
      $scope.person.month._myData = myData
    buildDataHourly = () ->
      MAX_BARS = 24
      hContrib = $scope.person.hour
      return if not hContrib
      myData = []
      formatHour = formatMonth
      for h in [0...MAX_BARS]
        tz = if not $scope.person.loc then 0 else $scope.person.loc.timezone
        realHour = (h - 7 - tz + 24) % 24
        myData[h] = [h + "", $scope.person.hour?[formatHour(realHour)] || 0]
      $scope.person.hour._myData = myData

    drawChartM1 = () ->
      MAX_BARS = 12
      language = $scope.person.month
      return if not language
      ###
      currentMonth = (new Date()).getMonth() + 1
      currentYear = (new Date()).getFullYear()
      myData = []
      month = currentMonth
      for m in [MAX_BARS...0]
        if month > 0
          myData[m-1] = [currentYear + "/" + month, $scope.person.month[String(currentYear)]?[formatMonth(month)] || 0]
        else
          lmonth = month + 12
          myData[m-1] = [String(currentYear-1) + "/" + lmonth, $scope.person.month[String(currentYear-1)]?[formatMonth(lmonth)] || 0]
        month--
      ###
      myData = $scope.person.month._myData
      $('#m-contrib-con').highcharts({
        chart:
            type: 'column'
            height: 300
        colors: ['#D97431']
        title:
            text: ''
        subtitle:
            text: ''
        xAxis:
            type: 'category'
        yAxis:
            min: 0
            title:
                text: ''
        legend:
            enabled: false
        tooltip:
            pointFormat: '贡献值: <b>{point.y}</b>'
        series: [{
            name: 'Contribution'
            data: myData
            dataLabels:
                enabled: true
                align: 'center'
                color: '#003366'
                x: 0
                y: 0
                style:
                    fontSize: '11px'
                    fontFamily: 'Verdana, sans-serif'
                    textShadow: '0 0 3px black'
        }]
      })
      return  
    # This is for jscharts.js. Remember to enable it in index.html.
    drawChartM = () ->
      MAX_BARS = 12
      language = $scope.person.month
      return if not language
      currentMonth = (new Date()).getMonth() + 1
      currentYear = (new Date()).getFullYear()
      myData = []
      month = currentMonth
      for m in [MAX_BARS...0]
        if month > 0
          myData[m-1] = [currentYear + "/" + month, $scope.person.month[String(currentYear)]?[formatMonth(month)] || 0]
        else
          lmonth = month + 12
          myData[m-1] = [String(currentYear-1) + "/" + lmonth, $scope.person.month[String(currentYear-1)]?[formatMonth(lmonth)] || 0]
        month--
      myChart = new JSChart('m-contrib-con', 'bar')
      myChart.setDataArray(myData)
      #myChart.setBarColor('#FCB08A')
      myChart.setBarColor('#D97431')
      myChart.setSize(700, 300)
      myChart.setTitle("Monthly Contribution")
      myChart.setTitleFontSize(12)
      myChart.setAxisNameY("")
      myChart.setAxisNameX("")
      myChart.setBarBorderWidth(0)
      myChart.draw()
      return

    drawChartH = () ->
      MAX_BARS = 24
      hContrib = $scope.person.hour
      return if not hContrib
      myData = []
      formatHour = formatMonth
      for h in [0...MAX_BARS]
        tz = if not $scope.person.loc then 0 else $scope.person.loc.timezone
        realHour = (h - 7 - tz + 24) % 24
        myData[h] = [h + "", $scope.person.hour?[formatHour(realHour)] || 0]
      myChart = new JSChart('h-contrib-con', 'bar')
      myChart.setDataArray(myData)
      #myChart.setBarColor('#FCB08A')
      myChart.setBarColor('#D97431')
      myChart.setSize(700, 300)
      myChart.setTitle("Hourly Contribution")
      myChart.setTitleFontSize(12)
      myChart.setAxisNameY("")
      myChart.setAxisNameX("")
      myChart.setBarBorderWidth(0)
      myChart.draw()
      return

    drawChartH1 = () ->
      ###
      MAX_BARS = 24
      hContrib = $scope.person.hour
      return if not hContrib
      myData = []
      formatHour = formatMonth
      for h in [0...MAX_BARS]
        tz = if not $scope.person.loc then 0 else $scope.person.loc.timezone
        realHour = (h - 7 - tz + 24) % 24
        myData[h] = [h + "", $scope.person.hour?[formatHour(realHour)] || 0]
      ###
      myData = $scope.person.hour._myData
      return if not myData or myData.length is 0
      $('#h-contrib-con').highcharts({
        chart:
          type: 'column'
          height: 300
        colors: ['#D97431']
        title:
          text: ''
        subtitle:
          text: ''
        xAxis:
          type: 'category'
          labels:
            align: 'center'
            style:
              fontSize: '11px'
              fontFamily: 'Verdana, sans-serif'
        yAxis:
          min: 0
          title:
            text: ''
        legend:
          enabled: false
        tooltip:
          pointFormat: '贡献值: <b>{point.y}</b>'
        series: [{
          name: 'Contribution'
          data: myData
          dataLabels:
            enabled: true,
            align: 'center'
            color: '#003366'
            x: 0
            y: 0
            style:
              fontSize: '11px'
              fontFamily: 'Verdana, sans-serif'
              textShadow: '0 0 3px black'
        }]
      })
      return

    drawChartD1 = () ->
      MAX_BARS = 7
      weekDay = ["Mon.", "Tue.", "Wen.", "Thu.", "Fri.", "Sat.", "Sun."]
      myData = []
      for h in [0...MAX_BARS]
        myData[h] = [weekDay[h], $scope.person.day?[h] || 0]
      $('#d-contrib-con').highcharts({
        chart:
          type: 'column'
          height: 300
        colors: ['#D97431']
        title:
          text: ''
        subtitle:
          text: ''
        xAxis:
          type: 'category'
          labels:
            align: 'center'
            style:
              fontSize: '11px'
              fontFamily: 'Verdana, sans-serif'
        yAxis:
          min: 0
          title:
            text: ''
        legend:
          enabled: false
        tooltip:
          pointFormat: '贡献值: <b>{point.y}</b>'
        series: [{
          name: 'Contribution'
          data: myData
          dataLabels:
            enabled: true,
            align: 'center'
            color: '#003366'
            x: 0
            y: 0
            style:
              fontSize: '11px'
              fontFamily: 'Verdana, sans-serif'
              textShadow: '0 0 3px black'
        }]
      })
      return

    drawLanguagePie1 = () ->
      return if not $scope.person?.lang
      langCount = objSize($scope.person.lang)
      return if langCount is 0
      MAX_BARS = 10
      MAX_BARS = if MAX_BARS > 10 then MAX_BARS else MAX_BARS
      myData = []
      for k, v of $scope.person.lang
        myData.push [k, v]
      myData.sort (a, b) ->
        return b[1] - a[1]
      myData.slice(0, MAX_BARS + 1)
      $('#lang-pie').highcharts({
          chart:
              plotBackgroundColor: null
              plotBorderWidth: null
              plotShadow: false
          title:
              text: ''
          tooltip:
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
          plotOptions:
              pie:
                  allowPointSelect: true
                  cursor: 'pointer'
                  dataLabels:
                      enabled: true
                      format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                      style:
                          color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                      connectorColor: 'silver'
          series: [{
              type: 'pie'
              name: 'languages'
              data: myData
          }]
      })
      return

    drawLanguagePie = () ->
      return if not $scope.person?.lang
      langCount = objSize($scope.person.lang)
      return if langCount is 0
      MAX_BARS = 10
      MAX_BARS = if MAX_BARS > 10 then MAX_BARS else MAX_BARS
      myData = []
      for k, v of $scope.person.lang
        myData.push [k, v]
      myData.sort (a, b) ->
        return b[1] - a[1]
      myData.slice(0, MAX_BARS + 1)
      myChart = new JSChart('lang-pie', 'pie')
      myChart.setDataArray(myData)
      #myChart.setBarColor('#FCB08A')
      myChart.setPieRadius(95)
      myChart.setTitle("")
      myChart.setSize(700, 300)
      myChart.setTitleFontSize(12)
      myChart.draw()
      return

    objSize = (obj) ->
      result = 0
      return result if not obj
      for k, v  of obj
        result++
      return result

    sortRepo = (a, b) ->
      return 0 if not a or not b
      return b.events - a.events
    # Sort a simple obj and return a sorted array of [[k1, v1], [k2, v2], ...]
    sortSimpleObject = (obj, asc) ->
      return [] if not obj
      result = []
      for k, v of obj
        result.push [k, v]
      result.sort (a, b) ->
        return if asc then a[1] - b[1] else b[1] - a[1]
    $scope.countScore = (lang) ->
      return 0 if not lang
      score = 0
      for key, value of lang
        for k, v of value
          score += v
      return score
    $scope.getWorldRank = (lang) ->
      result = $scope.person.rank.World[lang]
      return "N/A" if not result
      return if result > 50000 then "> 50000" else result
    composeLanguageDesc = () ->
      return "" if not $scope.person?._lang || $scope.person._lang.length is 0
      name = $scope.person._name
      desc = ""
      _language = $scope.person._lang
      #1
      if $scope.person._lang.length >= 10
        desc += "#{name}总共使用过#{$scope.person._lang.length}种语言，是个编程多面手。"
      else
        desc += "#{name}总共使用过#{$scope.person._lang.length}种语言。"
      #2
      if _language[0]?[1] and _language[0][1] >= 100
        if _language[1]?[1] and _language[1][1] >= 100
          if _language[2]?[1] and _language[2][1] >= 100
            desc += "#{name}最擅长的语言是#{_language[0][0]}，并且在#{_language[1][0]}和#{_language[2][0]}上也有不错的造诣。"
          else
            desc += "#{name}最擅长的语言是#{_language[0][0]}，并且在#{_language[1][0]}上也有不错的造诣。"
        else
          desc += "#{name}一直专注于#{_language[0][0]}的开发。"
      else if _language[0][1] and _language[0][1] > 0
        desc += "#{name}使用最多的语言是#{_language[0][0]}。"
      else
        desc += "#{name}似乎没有留下任何编程方面的记录。"
      return desc
    composeMonthlyDesc = () ->
      return "" if not $scope.person?.month?._myData || $scope.person.month._myData.length is 0
      desc = ""
      name = $scope.person._name
      sum = 0
      sum += value[1] for value in $scope.person.month._myData
      mean = sum / $scope.person.month._myData.length
      count = 0
      count++ for value in $scope.person.month._myData when value[1] < mean/2
      if mean <= 10
        desc = "#{name}在最近12个月的代码贡献总数并不多。"
      if count >= 3
        desc = "#{name}在最近12个月的代码贡献次数并不平均，在有些月份似乎忙于GitHub之外的事情。"
      else
        desc = "#{name}在最近12个月的代码贡献次数很平均，有着非常稳定的编程爱好。"
      return desc
    composeHourlyDesc = () ->
      data = $scope.person.hour._myData
      name = $scope.person._name
      i = 0; j = 0; k = 0; l = 0; m = 0;
      i += data[index][1] for index in [2..8]
      j += data[index][1] for index in [9..12]
      k += data[index][1] for index in [13..18]
      l += data[index][1] for index in [19..22]
      m = data[0][1] + data[1][1] + data[23][1]
      stat = [
        ["凌晨", i, i/7, "经常去米国工作吧？要不就是机器人！"]
        ["上午", j, j/4, "上午工作狂人。"]
        ["下午", k, k/6, "下午工作狂人。"]
        ["晚上", l, l/4, "晚上工作狂人，估计是没对象，没老婆，没小孩的三无人员..."]
        ["半夜", m, m/3, "半夜工作狂人。"]
      ]
      sum = 0
      sum += value[1] for value in data
      mean = sum / data.length
      sortedStat = stat.slice(0)
      sortedStat.sort (a, b) ->
        return b[2] - a[2]
      #maxIndex = 0
      #maxIndex = index for value, index in stat when value[1] > stat[maxIndex][1]
      hotSpans = []
      hotSpans.push value[0] for value, index in stat when value[2] > mean and value[0] isnt sortedStat[0][0]
      extra = if hotSpans.length > 0 then "， 在" + hotSpans.join("， ") + "时段也有很高的编程效率" else ""
      desc = "#{name}在#{sortedStat[0][0]}时段的编程效率最高#{extra}，是"
      if sortedStat[0][2] / sortedStat[1][2] >= 2
        desc += sortedStat[0][3]
      else
        #1
        condition = true
        condition = false for value in stat when value[2] < mean/5
        return desc += "24小时编程狂人，当然也有可能是悲催的的加班码农..." if condition is true
        #2
        condition = true
        condition = false for index in [1..4] when stat[index][2] < mean
        return desc += "全天候编程狂人，要不就是还睡觉，估计就是超人了。" if condition is true
        #3
        return desc += "典型的夜猫子编程爱好者。" if (sortedStat[0][0] is "晚上" and sortedStat[1][0] is "半夜") or (sortedStat[1][0] is "晚上" and sortedStat[0][0] is "半夜")
        #4
        return desc += "白天工作型编程人员。" if (sortedStat[0][0] is "上午" and sortedStat[1][0] is "下午") or (sortedStat[1][0] is "上午" and sortedStat[0][0] is "下午")
        return desc += "工作型编程人员。"

    $scope.getBlog = () ->
      return "" if not $scope.person?.info?.blog?
      return $scope.person.info.blog if $scope.person.info.blog.length <= 35
      return $scope.person.info.blog.substr(0, 35) + "..."
    $scope.getEmail = () ->
      return "" if not $scope.person?.info?.email?
      return $scope.person.info.email if $scope.person.info.email.length <= 16
      return $scope.person.info.email.substr(0, 16) + "..."

    buildData = () ->
      $scope.person._name = $scope.$parent.getName($scope.person)
      $scope.person._desc = $scope.$parent.getDesc($scope.person)
      $scope.person.repos.sort(sortRepo)
      $scope.person.repos = $scope.person.repos.slice(0, 5)
      $scope.person._rankChina = sortSimpleObject($scope.person.rank.China, true)
      $scope.person._lang = sortSimpleObject($scope.person.lang, false)
      buildDataMonthly()
      buildDataHourly()
      $scope.person._lang._desc = composeLanguageDesc()
      $scope.person.month._desc = composeMonthlyDesc()
      $scope.person.hour._desc = composeHourlyDesc()

    # We may need to retrieve data from server.
    if $scope.loginName
      $http.get("http://#{API_HOST}/github/users/#{$scope.loginName}")
        .success (data) ->
          $scope.person = data
          buildData()
          drawLanguagePie1()
          drawChartM1()
          drawChartH1()
          drawChartD1()
    return

  .controller 'ComingCtrl', ($rootScope, $scope, $route, $routeParams) ->
    $scope.$parent.currentTab = $route.current.originalPath.substr(1)
    $scope.sectionId = "modules"
    return
