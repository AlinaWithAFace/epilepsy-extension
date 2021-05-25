module Page.ListWarnings exposing (Model, Msg, init, update, view)

import Api exposing (Path, url)
import Error
import Html exposing (Html, button, div, h2, table, tbody, td, text, th, tr)
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
    , screeningStatus : WebData ()
    }


view : Model -> Html Msg
view model =
    case model.warnings of
        RemoteData.NotAsked ->
            div [ class "warning-body" ]
                [ viewMenu ]

        RemoteData.Loading ->
            div [ class "warning-body" ]
                [ viewMenu
                , div [ class "center" ]
                    [ h2 [ class "loading" ] [ text "loading..." ]
                    ]
                ]

        RemoteData.Success warnings ->
            div [ class "warning-body" ]
                ([ viewMenu ]
                    ++ viewStatus model.screeningStatus
                    ++ [ viewWarnings warnings
                       ]
                )

        RemoteData.Failure e ->
            div [ class "warning-body" ]
                [ viewMenu
                , div [ class "center" ] [ Error.view (Error.toString e) ]
                ]


viewMenu : Html Msg
viewMenu =
    div [ class "warning-menu" ]
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


viewStatus : WebData () -> List (Html Msg)
viewStatus status =
    case status of
        RemoteData.Success _ ->
            []

        _ ->
            [ div [ class "center" ] [ Error.view "Video is still being screened" ] ]


viewWarnings : Warnings -> Html Msg
viewWarnings warnings =
    if List.isEmpty warnings then
        div [ id "warnings" ]
            [ div [ class "no-warnings" ] [ text "No warnings to display" ]
            ]

    else
        div [ id "warnings" ] (List.map viewWarning warnings)


viewWarning : Warning -> Html Msg
viewWarning warning =
    let
        sourceToString s =
            case s of
                Warning.Automated ->
                    "Automated"

                Warning.UserGenerated ->
                    "User Generated"
    in
    table [ class "warning" ]
        [ tbody []
            [ tr []
                [ th [] [ text "Source" ]
                , td [] [ text (sourceToString warning.source) ]
                ]
            , tr []
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
    ( { warnings = RemoteData.NotAsked
      , path = path
      , screeningStatus =
            RemoteData.Loading
      }
    , createAutomatedWarnings path
    )


type Msg
    = ClickAll
    | ClickUser
    | ClickAuto
    | GotWarnings (WebData Warnings)
    | CreatedAutomatedWarnings (WebData ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreatedAutomatedWarnings status ->
            ( { model | screeningStatus = status }, getWarnings model.path Nothing )

        GotWarnings warnings ->
            ( { model | warnings = warnings }, Cmd.none )

        ClickAll ->
            ( model, getWarnings model.path Nothing )

        ClickAuto ->
            ( model, getWarnings model.path (Just "AUTO") )

        ClickUser ->
            ( model, getWarnings model.path (Just "USER") )


createAutomatedWarnings : Path -> Cmd Msg
createAutomatedWarnings path =
    Http.post
        { url = url (path ++ [ "warnings", "generate" ]) []
        , expect =
            Http.expectWhatever (RemoteData.fromResult >> CreatedAutomatedWarnings)
        , body = Http.emptyBody
        }


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
    let
        stringToSourceDecoder s =
            case s of
                "AUTO" ->
                    Decode.succeed Warning.Automated

                "USER" ->
                    Decode.succeed Warning.UserGenerated

                _ ->
                    Decode.fail "Invalid warning source"

        decodeSource =
            Decode.string
                |> Decode.andThen stringToSourceDecoder
    in
    Decode.map4
        Warning
        (Decode.map Time.fromInt (Decode.field "warning_start" Decode.int))
        (Decode.map Time.fromInt (Decode.field "warning_end" Decode.int))
        (Decode.field "warning_description" Decode.string)
        (Decode.field "warning_source" decodeSource)


decodeWarnings : Decode.Decoder Warnings
decodeWarnings =
    Decode.list decodeWarning
