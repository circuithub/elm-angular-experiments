module Giffy (Model, Action, init, update, view, angularActions) where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style,attribute,class,type')
import Html.Events exposing (onClick)
import Http
import Json.Decode as JsonD exposing (Decoder,(:=))
import Json.Encode as JsonE
import Task
import Elmgular.Action as A exposing (Angular)

-- MODEL

type alias Model =
    { topic : String
    , gifUrl : String
    , single : Bool
    }


init : String -> (Model, Effects Action)
init topic =
  ( Model topic "assets/waiting.gif" False
  , getRandomGif topic
  )


-- UPDATE

type Action
    = RequestMore
    | NewGif (Maybe String)
    | SetSingle Bool

angularActions : Angular Action
angularActions = A.merge [ A.make "RequestMore" RequestMore
                         , A.make1 "NewGif" NewGif (A.maybe A.argumentString)
                         , A.make1 "SetSingle" SetSingle (A.argumentBool)
                         ]

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    RequestMore ->
      (model, getRandomGif model.topic)

    NewGif maybeUrl ->
      ( Model model.topic (Maybe.withDefault model.gifUrl maybeUrl) model.single
      , Effects.none
      )

    SetSingle b -> ({model | single <- b}, Effects.none)


-- VIEW

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div [ style [ "width" => "200px" ] ]
    [ h2 [headerStyle] [text model.topic]
    , div [imgStyle model.gifUrl] []
    , button [ onClick address RequestMore ] [ text "More Please!" ]
    , node "elm-compile-angular" []
          [ pre [] [ text "{{model.single + ' - ' + model.gifUrl}}"]
          , button [ type' "button"
                   , class "btn btn-primary"
                   , attribute "ng-model" "model.single"
                   , attribute "btn-checkbox" ""
                   ] [ text "Toggle" ]
          , node "elm-react" [ attribute "elm-model" "model.single"
                             , attribute "elm-on-change" "actions.SetSingle"
                             ] []
          ]
    , node "elm-compile-angular" []
          [ pre [] [ text "{{model.single + ' - ' + model.gifUrl}}"]
          , button [ type' "button"
                   , class "btn btn-primary"
                   , attribute "ng-model" "model.single"
                   , attribute "btn-checkbox" ""
                   ] [ text "Toggle" ]
          , node "elm-react" [ attribute "elm-model" "model.single"
                             , attribute "elm-on-change" "actions.SetSingle"
                             ] []
          ]
    ]


headerStyle : Attribute
headerStyle =
  style
    [ "width" => "200px"
    , "text-align" => "center"
    ]


imgStyle : String -> Attribute
imgStyle url =
  style
    [ "display" => "inline-block"
    , "width" => "200px"
    , "height" => "200px"
    , "background-position" => "center center"
    , "background-size" => "cover"
    , "background-image" => ("url('" ++ url ++ "')")
    ]


-- EFFECTS

getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task


randomUrl : String -> String
randomUrl topic =
  Http.url "http://api.giphy.com/v1/gifs/random"
    [ "api_key" => "dc6zaTOxFJmzC"
    , "tag" => topic
    ]


decodeUrl : JsonD.Decoder String
decodeUrl =
  JsonD.at ["data", "image_url"] JsonD.string
