module Page.ListWarnings exposing (Model, Msg(..), init, update, view)

import Api exposing (url)
import Html exposing (Html, div, p, strong, text, br)
import Html.Attributes exposing (style)
import Http
import Json.Decode as Decode
import RemoteData exposing (WebData)
import Warning exposing (Warning)


type alias Model =
    { warnings : WebData (List Warning)
    }


init : List String -> ( Model, Cmd Msg )
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
            text "Loading warnings..."

        RemoteData.Success warnings ->
            div [] (List.map viewWarning warnings)

        RemoteData.Failure _ ->
            text "Internal Error"


viewWarning : Warning -> Html Msg
viewWarning warning =
    div [ style "border-top" "1px solid #000000" ]
        [ strong [] [ text "Start: " ]
        , text (String.fromInt warning.start)
        , br [] []
        , strong [] [ text "Stop: " ]
        , text (String.fromInt warning.stop)
        , br [] []
        , strong [] [ text "Description: " ]
        , text warning.description
        ]


getWarnings : List String -> Cmd Msg
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
