(angular.module "SomeController", ["Anglm","ui.bootstrap"])
.controller "someCtrl", ["$log", "$scope", "$timeout", ($log, $scope, $timeout) ->
  $log.info "Creating embedded controller"
  specific_url = "http://s3.amazonaws.com/giphygifs/media/mRfInPlisFzqM/giphy.gif"
  $timeout () ->
      $scope.elmActions.NewGif(specific_url)
    , 10000
]
