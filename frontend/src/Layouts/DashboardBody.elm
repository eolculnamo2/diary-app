module Layouts.DashboardBody exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)


dashboardBody : Html msg -> Html msg
dashboardBody children =
    div [ style "margin" "1em" ]
        [ children ]
