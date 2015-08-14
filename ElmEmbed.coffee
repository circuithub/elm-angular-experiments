Anglm = (angular.injector ['Anglm', 'ng']).get 'Anglm'
$log = (angular.injector ['ng']).get '$log'
elmApp = Elm.embed Elm.Client, document.getElementById('elm-root'), (actions: null)
$log.info "actions spec", elmApp.ports.spec
actions = Anglm.makeActions elmApp.ports.spec
$log.info "actions", actions

specific_url = "http://s3.amazonaws.com/giphygifs/media/mRfInPlisFzqM/giphy.gif"
$log.info "result action", actions.NewGif(specific_url)

$timeout = (angular.injector ['ng']).get '$timeout'
$timeout () ->
    elmApp.ports.actions.send actions.NewGif(specific_url)
    elmApp.ports.actions.send actions.RequestMore()
  , 1000
