module Pages.Dashboard exposing (Model, Msg, page)

import Array exposing (Array)
import Components.Header as Header
import Constants.Api exposing (api)
import Gen.Params.Dashboard exposing (Params)
import Html exposing (..)
import Html.Attributes exposing (style)
import Http exposing (expectJson)
import Json.Decode as Decode exposing (Decoder, field, int, string)
import Layouts.DashboardBody exposing (dashboardBody)
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
    { entries : Array Entry
    , entriesFailedErrMsg : Maybe String
    }


type alias Entry =
    { author : String
    , content : String
    , likes : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { entries = Array.empty, entriesFailedErrMsg = Nothing }, getEntries )



-- UPDATE


type Msg
    = EntriesLoaded (Result Http.Error (Array Entry))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EntriesLoaded result ->
            case result of
                Ok newEntries ->
                    ( { model | entries = newEntries }, Cmd.none )

                Err _ ->
                    ( { model | entriesFailedErrMsg = Just "Failed to load entries" }, Cmd.none )


decodeEntry : Decode.Decoder Entry
decodeEntry =
    Decode.map3 Entry
        (field "author" string)
        (field "content" string)
        (field "likes" int)


decodeEntryArray : Decode.Decoder (Array Entry)
decodeEntryArray =
    Decode.array decodeEntry


getEntries : Cmd Msg
getEntries =
    Http.get
        { url = api ++ "/get-entries"
        , expect = Http.expectJson EntriesLoaded decodeEntryArray
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


entryView : Entry -> Html msg
entryView entry =
    div []
        [ h5 [] [ text entry.author ]
        , p [] [ text entry.content ]
        , div []
            [ strong [] [ text "Likes " ]
            , span [] [ text (entry.likes |> String.fromInt) ]
            ]
        ]


view : Model -> View Msg
view model =
    { title = "Dashboard"
    , body =
        [ Header.main
        , dashboardBody
            (div []
                [ h3 [] [ text "Entries List" ]
                , div []
                    (model.entries
                        |> Array.map entryView
                        |> Array.toList
                    )
                ]
            )
        , case model.entriesFailedErrMsg of
            Nothing ->
                span [] []

            Just errorMsg ->
                div [ style "color" "red" ] [ text errorMsg ]
        ]
    }
