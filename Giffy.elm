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
import Elmgular.Html as A

-- MODEL

type alias Slide =
  { image: String
  , text: String
  , active: Bool
  }

type alias Model =
    { topic : String
    , slides : List Slide
    , single : Bool
    }


init : String -> (Model, Effects Action)
init topic =
  ( Model topic [Slide "assets/waiting.gif" "" False] True
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
      let newSlides = case (maybeUrl, model.single) of
                    (Nothing, _) -> model.slides
                    (Just url, True)  -> [Slide url "" False]
                    (Just url, False) -> Slide url "" False :: model.slides
      in ({model | slides <- newSlides}, Effects.none)

    SetSingle b -> ({model | single <- b}, Effects.none)


-- VIEW

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div [ style [ "width" => "200px" ] ]
    [ h2 [headerStyle] [text model.topic]
    , div [imgStyle (List.head model.slides |> Maybe.withDefault (Slide "" "" False) |> .image)] []
    , button [ onClick address RequestMore ] [ text "More Please!" ]
    , A.embed
        [ node "carousel" [ attribute "interval" "5000"
                          , attribute "no-wrap" "false"]
            [ node "slide" [ attribute "ng-repeat" "slide in elmModel.slides"
                           , attribute "active" "slide.active"
                           ]
                [ img [ attribute "ng-src" "{{slide.image}}"
                      , style ["margin"=>"auto"]
                      ] []
                , div [class "carousel-caption"]
                    [ h4 [] [text "Slide {{$index}}"]
                    , p [] [text "{{slide.text}}"]
                    ]
                ]
            ]
        ]
    , A.embed
        [ pre [] [ text "{{elmModel.single + ' - ' + elmModel.slides}}"]
        , button [ type' "button"
                 , class "btn btn-primary"
                 , attribute "ng-model" "elmModel.single"
                 , attribute "btn-checkbox" ""
                 ] [ text "Toggle" ]
        , A.react "elmModel.single" "elmActions.SetSingle"
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
