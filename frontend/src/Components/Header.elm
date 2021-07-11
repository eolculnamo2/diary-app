module Components.Header exposing (..)

import Html exposing (Html, text)
import Material.IconButton as IconButton
import Material.TopAppBar as TopAppBar


main : Html msg
main =
    TopAppBar.regular
        (TopAppBar.config
            |> TopAppBar.setFixed False
        )
        [ TopAppBar.row []
            [ TopAppBar.section [ TopAppBar.alignStart ]
                [ IconButton.iconButton
                    (IconButton.config
                        |> IconButton.setAttributes
                            [ TopAppBar.navigationIcon ]
                    )
                    (IconButton.icon "menu")
                , Html.span [ TopAppBar.title ]
                    [ text "Rob's Elm Diary App" ]
                ]
            ]
        ]
