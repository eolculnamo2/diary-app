module Pages.Home_ exposing (view)

import Components.Header as Header
import Html exposing (..)
import Html.Attributes exposing (href)
import Layouts.DashboardBody exposing (dashboardBody)
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , body =
        [ Header.main
        , dashboardBody
            (div []
                [ h1 [] [ text "Welcome to my simple diary app" ]
                , p [] [ text "This project is for me to experiment with the Elm/Haskell stack" ]
                , a [ href "/login" ] [ text "Click here to login" ]
                ]
            )
        ]
    }
