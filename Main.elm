module Main exposing (..)

import Browser exposing (init, update, view, subscriptions)
import Html.App as Html


main : Program Never
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
