Anglm = (angular.injector ['Anglm', 'ng']).get 'Anglm'
elmApp = Elm.embed Elm.Client, document.getElementById('elm-root')
Anglm.printInteropSpec elmApp.ports.spec
