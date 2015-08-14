Anglm = (angular.injector ['Anglm', 'ng']).get 'Anglm'
$log = (angular.injector ['ng']).get '$log'
elmApp = Elm.embed Elm.Client, document.getElementById('elm-root')
$log.info elmApp.ports.spec
# actions = Anglm.makeActions elmApp.ports.spec
# $log.info actions
# $log.info actions.RequestMore()
