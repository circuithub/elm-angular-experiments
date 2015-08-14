module Client where
import Effects exposing (Never)
import Giffy exposing (init, update, view, angularActions)
import StartApp
import Task
import Json.Encode as Json


app =
  StartApp.start
    { init = init "funny cats"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

port spec : Json.Value
port spec = snd angularActions


