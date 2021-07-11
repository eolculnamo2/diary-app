module Pages.Login exposing (Model, Msg, page)

import Components.Header as Header
import Constants.Api exposing (api)
import Gen.Params.Login exposing (Params)
import Html exposing (..)
import Html.Attributes exposing (href, style)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Layouts.DashboardBody exposing (dashboardBody)
import Material.Button as Button
import Material.TextField as TextField
import Page
import Request
import Shared
import Url exposing (Protocol(..))
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { username : String
    , password : String
    }


init : ( Model, Cmd Msg )
init =
    ( { username = "", password = "" }, Cmd.none )



-- UPDATE


type Msg
    = UsernameUpdated String
    | PasswordUpdated String
    | ClickedLogin
    | LoginRequested (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UsernameUpdated usernameUpdate ->
            ( { model | username = usernameUpdate }, Cmd.none )

        PasswordUpdated passwordUpdate ->
            ( { model | password = passwordUpdate }, Cmd.none )

        ClickedLogin ->
            ( model, Cmd.none )

        LoginRequested result ->
            case result of
                Ok _ ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias LoginPost =
    { username : String
    , password : String
    }


encodeLoginJson : LoginPost -> Encode.Value
encodeLoginJson loginPost =
    Encode.object
        [ ( "username", Encode.string loginPost.username )
        , ( "password", Encode.string loginPost.password )
        ]


login : LoginPost -> Cmd Msg
login loginRequest =
    Http.post
        { url = api ++ "/login"
        , body = encodeLoginJson loginRequest |> Http.jsonBody
        , expect = Http.expectString LoginRequested
        }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Login"
    , body =
        [ Header.main
        , dashboardBody
            (div []
                [ h1 [] [ text "Login!" ]
                , p []
                    [ text "Login to view and create diary entries" ]
                , a
                    [ href "/", style "display" "block", style "margin-top" "1em" ]
                    [ text "Home" ]
                , div
                    [ style "width" "500px", style "margin" "auto" ]
                    [ h3 [] [ text "Login" ]
                    , TextField.filled
                        (TextField.config
                            |> TextField.setLabel (Just "Username")
                            |> TextField.setValue (Just model.username)
                            |> TextField.setOnInput UsernameUpdated
                            |> TextField.setAttributes [ style "display" "block" ]
                        )
                    , TextField.filled
                        (TextField.config
                            |> TextField.setLabel (Just "Passwrd")
                            |> TextField.setValue (Just model.password)
                            |> TextField.setOnInput PasswordUpdated
                            |> TextField.setAttributes [ style "display" "block", style "margin-top" "1em" ]
                            |> TextField.setType (Just "password")
                        )
                    , Button.text
                        (Button.config |> Button.setOnClick ClickedLogin |> Button.setAttributes [ style "float" "right" ])
                        "Login"
                    ]
                ]
            )
        ]
    }
