(angular.module "Anglm", [])
.factory "Anglm", ["$log",  ($log) ->

  printActionsSpec: (spec) -> $log.info spec

  makeActions: (spec) -> action
]

#action = (s) ->

