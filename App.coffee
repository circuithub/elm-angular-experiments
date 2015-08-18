(angular.module "App", ["Anglm", "Embed", "ui.bootstrap"])
.controller "appCtrl", ["$log", "$scope", ($log, $scope) ->
  $log.info "Creating application controller"
  $scope.message = "yet!"
]

