import Browser exposing (init, update, view)
import Effects exposing (Never)
import Keyboard
import Signal exposing ((<~))
import StartApp
import Task


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [ Browser.KeyPress <~ Keyboard.arrows ]
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
