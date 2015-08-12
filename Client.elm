module Client where

import Html exposing (div, ul, span, button, Attribute, a)
import Html.Lazy exposing (lazy2)
import Html.Events as Html exposing (onClick)
import Html.Attributes as Html exposing (class, type', href)
import Html.Shorthand exposing (..)
import Bootstrap.Html exposing (..)
import Html exposing (blockquote)
import Html exposing (Html, text, toElement, fromElement)
import Signal exposing (Address)
import VirtualDom exposing (attribute)
import Debug exposing (log)
--
-- Model
--
port initialLocation : String

type Action =
            NavSignIn
            | NavPage1
            | NavPage2

type alias Model = {
    page : String
}

initialModel : Model
initialModel =
    { page = if (log "loc:" initialLocation) == ""
                then "page1" else initialLocation }

--
-- Plumbing
--

actions : Signal.Mailbox Action
actions =
    Signal.mailbox NavPage1

update : Action -> Model -> Model
update act model = case act of
    NavSignIn -> { model | page <- "signin" }
    NavPage1  -> { model | page <- "page1" }
    NavPage2  -> { model | page <- "page2" }


model : Signal Model
model = Signal.foldp update initialModel actions.signal


main : Signal Html
main = Signal.map (view actions.address) model

--
-- View
--

getInner : Address Action -> Model -> Html
getInner addr model =
        case model.page of
            "signin" -> lazy2 signin addr model
            "page1"  -> lazy2 page1 addr model
            "page2"  -> lazy2 page2 addr model

view : Address Action -> Model -> Html
view addr model =
    containerFluid_
        [ lazy2 navb addr model
        , getInner addr model ]


page1 : Address Action -> Model -> Html
page1 addr model = div' { class="jumbotron" } [ h2_ "Page One" ]


page2 : Address Action -> Model -> Html
page2 addr model = div' { class="jumbotron" } [ h2_ "Page Two" ]


signin : Address Action -> Model -> Html
signin addr model = div' { class="jumbotron" } [ h2_ "Sign In" ]

navb : Address Action -> Model -> Html
navb addr model =
    navbar' "navbar navbar-inverse navbar-static-top"
        [containerFluid_
            [ navbarHeader_
                [ a' {class="navbar-brand", href="#"} [text "Elm Bootstrap Skeleton" ]
                , button cButtonAttrs hamburger ]
            , div [ class "navbar-collapse collapse" ]
                [ul [ class "nav navbar-nav navbar-right" ]
                    [ li_ [a [ class "active", href "#/page1", onClick addr NavPage1 ] [ text "Page 1" ]]
                    , li_ [a [ class "", href "#/page2", onClick addr NavPage2  ] [ text "Page 2" ]]
                    , li_ [a [ class "", href "#/signin", onClick addr NavSignIn ] [ text "Sign In" ]]
                    ]
                ]
            ]
        ]

cButtonAttrs : List Attribute
cButtonAttrs =
          [ type' "button"
          , class "navbar-toggle"
          , attribute "data-toggle" "collapse"
          , attribute "data-target" ".navbar-collapse"]

hamburger : List Html
hamburger =
    [ span [class "sr-only"] []
    , span [class "icon-bar"] []
    , span [class "icon-bar"] []
    , span [class "icon-bar"] []
    ]
