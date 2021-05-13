module Page.ListWarnings exposing (Model, Msg(..), init, update, view)

import Api exposing (Path, url)
import Html exposing (Html, br, div, h2, p, strong, table, tbody, td, text, th, tr)
import Html.Attributes exposing (class, id)
import Http
import Json.Decode as Decode
import RemoteData exposing (WebData)
import Warning exposing (Warning)


type alias Model =
    { warnings : WebData (List Warning)
    }


init : Path -> ( Model, Cmd Msg )
init path =
    ( { warnings = RemoteData.Loading }, getWarnings path )


type Msg
    = GotWarnings (WebData (List Warning))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotWarnings response ->
            ( { model | warnings = response }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.warnings of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text ""

        RemoteData.Success warnings ->
            div [ id "warnings" ] (List.map viewWarning warnings)

        RemoteData.Failure _ ->
            text "Internal Error"


viewWarning : Warning -> Html Msg
viewWarning warning =
    table [ class "warning" ]
        [ tbody []
            [ tr []
                [ th [] [ text "Start" ]
                , td [] [ text (String.fromInt warning.start) ]
                ]
            , tr []
                [ th [] [ text "Stop" ]
                , td [] [ text (String.fromInt warning.stop) ]
                ]
            , tr []
                [ th [] [ text "Description" ]
                , td [] [ text warning.description ]
                ]
            ]
        ]


getWarnings : Path -> Cmd Msg
getWarnings path =
    Http.get
        { url = url (path ++ [ "warnings" ]) []
        , expect =
            Http.expectJson
                (RemoteData.fromResult >> GotWarnings)
                decodeWarnings
        }


decodeWarning : Decode.Decoder Warning
decodeWarning =
    Decode.map3
        Warning
        (Decode.field "warning_start" Decode.int)
        (Decode.field "warning_end" Decode.int)
        (Decode.field "warning_description" Decode.string)


decodeWarnings : Decode.Decoder (List Warning)
decodeWarnings =
    Decode.list decodeWarning
