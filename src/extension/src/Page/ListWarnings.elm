module Page.ListWarnings exposing (Model, Msg, init, update, view)

import Api exposing (Path, url)
import Error
import Html exposing (Html, button, div, table, tbody, td, text, th, tr)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (WebData)
import Time exposing (Time)
import Url.Builder
import Warning exposing (Warning)


type alias Warnings =
    List Warning


type alias Model =
    { warnings : WebData Warnings
    , path : Path
    }


view : Model -> Html Msg
view model =
    case model.warnings of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text ""

        RemoteData.Success warnings ->
            div [ class "warning-body" ]
                [ div [ class "warning-menu" ]
                    [ button
                        [ onClick ClickAll ]
                        [ text "All Warnings" ]
                    , button
                        [ onClick ClickAuto ]
                        [ text "Automated Warnings" ]
                    , button
                        [ onClick ClickUser ]
                        [ text "User Created Warnings" ]
                    ]
                , viewWarnings warnings
                ]

        RemoteData.Failure e ->
            div [ class "center" ] [ Error.view (Error.toString e) ]


viewWarnings : Warnings -> Html Msg
viewWarnings warnings =
    if List.isEmpty warnings then
        div [ class "center" ] [ Error.view "No warnings found" ]

    else
        div [ id "warnings" ] (List.map viewWarning warnings)


viewWarning : Warning -> Html Msg
viewWarning warning =
    table [ class "warning" ]
        [ tbody []
            [ tr []
                [ th [] [ text "Start" ]
                , td [] [ text (Time.toString warning.start) ]
                ]
            , tr []
                [ th [] [ text "Stop" ]
                , td [] [ text (Time.toString warning.stop) ]
                ]
            , tr []
                [ th [] [ text "Description" ]
                , td [] [ text warning.description ]
                ]
            ]
        ]


init : Path -> ( Model, Cmd Msg )
init path =
    ( { warnings = RemoteData.Loading, path = path }, getWarnings path Nothing )


type Msg
    = ClickAll
    | ClickUser
    | ClickAuto
    | GotWarnings (WebData Warnings)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotWarnings warnings ->
            ( { model | warnings = warnings }, Cmd.none )

        ClickAll ->
            ( model, getWarnings model.path Nothing )

        ClickAuto ->
            ( model, getWarnings model.path (Just "AUTO") )

        ClickUser ->
            ( model, getWarnings model.path (Just "USER") )


getWarnings : Path -> Maybe String -> Cmd Msg
getWarnings path query =
    let
        queryParams =
            case query of
                Nothing ->
                    []

                Just q ->
                    [ Url.Builder.string "source" q ]
    in
    Http.get
        { url = url (path ++ [ "warnings" ]) queryParams
        , expect =
            Http.expectJson
                (GotWarnings << RemoteData.fromResult)
                decodeWarnings
        }


decodeWarning : Decoder Warning
decodeWarning =
    Decode.map3
        Warning
        (Decode.map Time.fromInt (Decode.field "warning_start" Decode.int))
        (Decode.map Time.fromInt (Decode.field "warning_end" Decode.int))
        (Decode.field "warning_description" Decode.string)


decodeWarnings : Decode.Decoder Warnings
decodeWarnings =
    Decode.list decodeWarning
