console.log "blah"
(angular.module "Embed", ["Anglm"])
.controller "embedElmCtrl", ["$log", "$scope", ($log, $scope) ->
  $log.info "creating controller"
  $scope.message = "yet!"
]
.directive "embedElm", ["$log", "$timeout", "Anglm",  ($log, $timeout, Anglm) ->
  $log.info "creating directive"
  def =
    scope: {}
    restrict: "E"
    replace: true
    template: '<div> </div>'
    link: (scope, elemWrp, attrs) ->
      elem = elemWrp.get(0)
      $log.info "linking directive - elm-root = ", elem
      elmApp = Elm.embed Elm.Client, elem, (actions: null)
      $log.info "actions spec", elmApp.ports.spec
      actionsManual = Anglm.makeActions elmApp.ports.spec
      scope.actions = Anglm.makeActions elmApp.ports.spec, elmApp.ports.actions.send

      scope.model = {}
      elmApp.ports.model.subscribe (m) -> scope.$apply (scope) -> _.assign scope.model, m

      specific_url = "http://s3.amazonaws.com/giphygifs/media/mRfInPlisFzqM/giphy.gif"
      $timeout () ->
          elmApp.ports.actions.send actionsManual.NewGif(specific_url)
        , 2000

      $timeout = (angular.injector ['ng']).get '$timeout'
      $timeout () ->
          scope.actions.RequestMore()
        , 5000

      $timeout = (angular.injector ['ng']).get '$timeout'
      $timeout () ->
          scope.actions.RequestMore()
          scope.actions.NewGif(specific_url)
        , 7000
  return def
]

