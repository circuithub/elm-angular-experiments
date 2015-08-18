(angular.module "Embed", ["Anglm","ui.bootstrap"])
.controller "embedCtrl", ["$log", "$scope", "$timeout", ($log, $scope, $timeout) ->
  $log.info "Creating embedded controller"
  specific_url = "http://s3.amazonaws.com/giphygifs/media/mRfInPlisFzqM/giphy.gif"
  $timeout () ->
      $scope.elmActions.NewGif(specific_url)
    , 2000
]
