module App where
import Effects exposing (Never, Effects)
import Giffy exposing (init, update, view, angularActions, Action,Model)
import StartApp
import Task
import Json.Encode as Json
import Json.Decode exposing (decodeValue)
import Signal exposing ((<~),Address,forwardTo,Signal)
import Html exposing (Html)
import Debug exposing (crash)


app =
  StartApp.start
    { init = init'
    , update = update'
    , view = view'
    , inputs = [ decodeAction <~ actions ]
    }

init' : (Model, Effects (Maybe Action))
init' = let (m,e) = init "funny cats" in (m, Effects.map Just e)

view' : Address (Maybe Action) -> Model -> Html
view' a m = view (forwardTo a Just) m

update' : Maybe Action -> Model -> (Model, Effects (Maybe Action))
update' a m = case a of
  Just a' -> let (m',e) = update a' m in (m', Effects.map Just e)
  Nothing -> (m, Effects.none)


main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks

port spec : Json.Value
port spec = snd angularActions

port model : Signal Model
port model = app.model

port actions : Signal (Json.Value)

decodeAction : Json.Value -> Maybe Action
decodeAction js = case decodeValue (fst angularActions |> Json.Decode.maybe) js of
                    Result.Ok v -> v
                    Result.Err e -> e
                                 |> Debug.log "error decoding action"
                                 |> always (Json.encode 0 js)
                                 |> Debug.log "JSON was"
                                 |> always Nothing

