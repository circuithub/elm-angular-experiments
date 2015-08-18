(angular.module "Anglm", [])
.factory "Anglm", [() ->

  makeActions: (spec, port=_.identity) -> makeActions(spec, port)
  makeEmbedDirective: ($compile, elmModule, initModule) -> embedDirective($compile, elmModule, initModule)
  makeReactDirective: () -> reactDirective()
]
.directive "anglmReact", [() -> reactDirective() ]
.directive "anglmEmbed", ["$compile", ($compile) -> embedDirective($compile) ]
.directive "anglmEmbedActionsInitModel", ["$compile", ($compile) -> embedDirective($compile, exposeActions: true , exposeInit: true , exposeModel: true )]
.directive "anglmEmbedActionsModel"    , ["$compile", ($compile) -> embedDirective($compile, exposeActions: true , exposeInit: false, exposeModel: true )]
.directive "anglmEmbedActionsInit"     , ["$compile", ($compile) -> embedDirective($compile, exposeActions: true , exposeInit: true , exposeModel: false)]
.directive "anglmEmbedInitModel"       , ["$compile", ($compile) -> embedDirective($compile, exposeActions: false, exposeInit: true , exposeModel: true )]
.directive "anglmEmbedModel"           , ["$compile", ($compile) -> embedDirective($compile, exposeActions: false, exposeInit: false, exposeModel: true )]
.directive "anglmEmbedActions"         , ["$compile", ($compile) -> embedDirective($compile, exposeActions: true , exposeInit: false, exposeModel: false)]
.directive "anglmEmbedInit"            , ["$compile", ($compile) -> embedDirective($compile, exposeActions: false, exposeInit: true , exposeModel: false)]

#debug hack to allow loggin
getLog = do ()->
  $log = null
  ()->
    $log ? $log = (angular.injector ['ng']).get '$log'

reactDirective = () ->
  def =
    restrict: "E"
    template: "<div> </div>"
    replace: true
    link: (scope, elem, attrs) ->
      onChange = (scope.$eval attrs['elmOnChange'])
      if not onChange?
        throw "Anglm - reactDirective elm-on-change not defined"
      model = attrs['elmModel']
      if not model?
        throw "Anglm - reactDirective elm-model not defined"
      # TODO: Verify $watch seems to trigger first with undefined then with initial
      #       value. Only want to react to changes so skip undefineds and initial value
      firstValid = true
      scope.$watch model, (val) ->
        if val isnt undefined
          if not firstValid
            onChange val
          firstValid = false

  return def

#note $compile needs to be passed in from module that injects it so that all the other directives are in scope
embedDirective = ($compile, options) ->
  def =
    scope: {}
    restrict: "E"
    replace: true
    template: '<div> <div> </div> </div>'
    link: (scope, elem, attrs) ->
      elmModule = options?.elmModule ? Elm[scope.elmModule]
      elmRoot = elem.children().get(0)
      elmApp = Elm.embed elmModule, elmRoot, getElmInit scope, options
      initElmActions scope, elmApp

      compileAngular $compile, scope, elem

      elmApp.ports.model.subscribe (elmModel) ->
        updateAngularModal(scope, elmModel)
        compileAngular $compile, scope, elem

  if not options?.elmModule? then def.scope.elmModule = "@"
  if options?.exposeInit then def.scope.elmInit = "@"
  if options?.exposeActions then def.scope.elmActions = "="
  if options?.exposeModel then def.scope.elmModel = "="

  return def

getElmInit = (scope, options) ->
  check = (m) ->
    if not _.isPlainObject m
      throw "Anglm - the model used to initialize the ELM module must be a simple object"
    return (initModule: m, actions: null)
  return check options.elmInit if options?.elmInit?
  return check (JSON.parse scope.elmInit) if _.isString scope.elmInit
  return check scope.elmInit if _.isObject scope.elmInit
  return (actions: null)


initElmActions = (scope, elmApp) ->
  if not scope.elmActions?
    scope.elmActions = {}
  _.assign scope.elmActions, (makeActions elmApp.ports.spec, elmApp.ports.actions.send)
  return scope

updateAngularModal = (scope, elmModel) ->
  scope.$apply (scope) ->
    if not scope.elmModel?
      scope.elmModel = {}
    _.assign scope.elmModel, elmModel
  return scope

compileAngular = ($compile, scope, elem) ->
  targets = elem.find('anglm-compile')
  for i in [0 .. targets.length - 1]
    e = targets.eq(i)
    if not e.prop("anglm-compiled")
      e.prop("anglm-compiled", true)
      ($compile e) scope

makeActions = (s, ctx) ->
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
  if not argSpec?
    throw "Anglm.makeActions - argSpec is null"
    return null
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

