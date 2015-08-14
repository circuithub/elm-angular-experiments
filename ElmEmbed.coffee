Anglm = (angular.injector ['Anglm', 'ng']).get 'Anglm'
$log = (angular.injector ['ng']).get '$log'
elmApp = Elm.embed Elm.Client, document.getElementById('elm-root'), (actions: null)
$log.info "actions spec", elmApp.ports.spec
actions = Anglm.makeActions elmApp.ports.spec
actionsB = Anglm.makeActions elmApp.ports.spec, elmApp.ports.actions.send
$log.info "actions", actions

specific_url = "http://s3.amazonaws.com/giphygifs/media/mRfInPlisFzqM/giphy.gif"
$log.info "result action", actions.NewGif(specific_url)

$timeout = (angular.injector ['ng']).get '$timeout'
$timeout () ->
    elmApp.ports.actions.send actions.NewGif(specific_url)
  , 2000

$timeout = (angular.injector ['ng']).get '$timeout'
$timeout () ->
    actionsB.RequestMore()
  , 5000

$timeout = (angular.injector ['ng']).get '$timeout'
$timeout () ->
    actionsB.RequestMore()
    elmApp.ports.actions.send actions.NewGif(specific_url)
  , 7000
