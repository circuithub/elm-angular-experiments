(angular.module "Anglm", [])
.factory "Anglm", ["$log",  ($log) ->

  makeActions: (spec, port=_.identity) -> mkActions(spec, port)
]

$log = (angular.injector ['ng']).get '$log'

mkActions = (s, ctx) ->
  if _.isArray s
   r = {}
   for ss in s
    _.assign r, (mkAction ss, ctx)
   return r
  else
   return (mkAction s, ctx)

mkAction = (s, ctx) ->
  a = _.compact [(action s, ctx), (actionN s, ctx)]
  if a.length isnt 1
    throw "Anglm.makeActions - ambiguity found "
  else
    return a[0]

action = (s,ctx) ->
  if not (_.isEmpty (_.omit s, ["tag"])) or not s.tag?
    return null
  else
    return  "#{s.tag}": () -> ctx s

actionN = (s, ctx) ->
  if not (_.isEmpty (_.omit s, ["tag","args"])) or not (s.tag? and s.args?)
    return null
  else
    return "#{s.tag}": (a...) ->
      r =
        tag: s.tag
        args: (_.map (_.zip s.args, a), decodeArg)
      return ctx r

maybePfx = "ArgumentTagMaybe "
decodeArg = ([argSpec, argValue]) ->
  if argSpec.slice(0,maybePfx.length) is maybePfx
    return if argValue? then decodeArg [(argSpec.slice(maybePfx.length)), argValue] else null
  if argSpec == "ArgumentTagInt"
    throw "Anglm.makeActions - expecting an integer" if not _.isNumber argValue or (Math.ceil argValue isnt argValue)
    return argValue
  if argSpec == "ArgumentTagFloat"
    throw "Anglm.makeActions - expecting a float" if not _.isNumber argValue
    return argValue
  if argSpec == "ArgumentTagString"
    throw "Anglm.makeActions - expecting a string" if not _.isString argValue
    return argValue
  if argSpec == "ArgumentTagBool"
    throw "Anglm.makeActions - expecting a boolean" if not _.isBoolean argValue
    return argValue
  throw "Anglm.makeActions - JS and ELM diverged. Don't know how to handle #{argSpec} as an argument"

