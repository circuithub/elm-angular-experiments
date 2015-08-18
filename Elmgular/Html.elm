module Elmgular.Html (embed, react) where
import Html exposing (..)
import Html.Attributes exposing (style,attribute,class,type')


embed : List Html -> Html
embed = node "anglm-compile" []

react : String -> String -> Html
react sModel sAction = node "anglm-react"  [ attribute "elm-model" sModel
                                           , attribute "elm-on-change" sAction
                                           ][]
