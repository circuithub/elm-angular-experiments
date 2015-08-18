console.log "blah"
(angular.module "Embed", ["Anglm","ui.bootstrap"])
.controller "embedElmCtrl", ["$log", "$scope", ($log, $scope) ->
  $log.info "creating controller"
  $scope.message = "yet!"
]
.directive "elmReact", ["$log", ($log) ->
  def =
    restrict: "E"
    template: "<div> </div>"
    replace: true
    link: (scope, elem, attrs) ->
      onChange = (scope.$eval attrs['elmOnChange'])
      scope.$watch attrs['elmModel'], (val) ->
        $log.info attrs['elmModel'], val
        onChange val

]
.directive "embedElm", ["$log", "$timeout", "$compile", "Anglm",  ($log, $timeout, $compile, Anglm) ->
  $log.info "creating directive"
  def =
    scope: {}
    restrict: "E"
    replace: true
    template: '<div> <div> </div> </div>'
    link: (scope, elemWrp, attrs) ->
      elmRoot = elemWrp.children().get(0)
      elmApp = Elm.embed Elm.Client, elmRoot, (actions: null)
      actionsManual = Anglm.makeActions elmApp.ports.spec
      scope.actions = Anglm.makeActions elmApp.ports.spec, elmApp.ports.actions.send

      scope.model = {}
      updateAngularModal = (m) ->
        scope.$apply (scope) -> _.assign scope.model, m

      compileAngular = () ->
        targets = elemWrp.find('elm-compile-angular')
        for i in [0 .. targets.length - 1]
          e = targets.eq(i)
          if not e.prop("elm-compiled-angular")
            e.prop("elm-compiled-angular", true)
            $compile(e)(scope)
      compileAngular()

      elmApp.ports.model.subscribe (m) ->
        updateAngularModal(m)
        compileAngular()

      specific_url = "http://s3.amazonaws.com/giphygifs/media/mRfInPlisFzqM/giphy.gif"
      $timeout () ->
          elmApp.ports.actions.send actionsManual.NewGif(specific_url)
        , 2000

      #$timeout = (angular.injector ['ng']).get '$timeout'
      #$timeout () ->
          #scope.actions.RequestMore()
        #, 5000

      #$timeout = (angular.injector ['ng']).get '$timeout'
      #$timeout () ->
          #scope.actions.RequestMore()
          #scope.actions.NewGif(specific_url)
        #, 7000
  return def
]

