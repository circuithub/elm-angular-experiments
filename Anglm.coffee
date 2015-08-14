(angular.module "Anglm", [])
.factory "Anglm", ["$log",  ($log) ->

  makeActions: (spec) -> mkActions(spec)
]

$log = (angular.injector ['ng']).get '$log'

mkActions = (s) ->
  $log.info "mkActions", s
  if _.isArray s
   r = {}
   return _.assign r, (mkAction ss) for ss in s
  else
   return mkAction (s)

mkAction = (s) ->
  a = action (s)
  return a if a?

action = (s) ->
  return null if not _.isEmpty (_.omit s, ["tag"])
  return  "#{s.tag}": () -> s


