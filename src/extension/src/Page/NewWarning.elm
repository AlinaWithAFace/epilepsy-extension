module Page.NewWarning exposing (Model, Msg(..), init, update, view)

import Api exposing (Path, url)
import Html exposing (Html, div, form, h2, input, label, text, textarea)
import Html.Attributes exposing (id, class, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Encode as Encode
import RemoteData exposing (WebData)
import Warning exposing (Warning)


type alias Form =
    { path : Path
    , start : Maybe Int
    , stop : Maybe Int
    , description : Maybe String
    , error : Maybe String
    }


type Model
    = InProgress Form
    | Success (WebData ())


init : Path -> ( Model, Cmd Msg )
init path =
    ( InProgress
        { path = path
        , start = Nothing
        , stop = Nothing
        , description = Nothing
        , error = Nothing
        }
    , Cmd.none
    )


type Msg
    = CreatedWarning (WebData ())
    | SubmitWarning
    | InputStart String
    | InputStop String
    | InputDescription String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( CreatedWarning w, Success _ ) ->
            ( Success w, Cmd.none )

        ( _, Success _ ) ->
            ( model, Cmd.none )

        ( _, InProgress m ) ->
            case ( msg, ( m.start, m.stop, m.description ) ) of
                ( SubmitWarning, ( Just start, Just stop, Just desc ) ) ->
                    ( Success RemoteData.Loading
                    , createWarning
                        m.path
                        { start = start
                        , stop = stop
                        , description = desc
                        }
                    )

                ( SubmitWarning, ( Nothing, Just _, Just _ ) ) ->
                    ( InProgress { m | error = Just "Missing field \"Start\n                    Time\"" }, Cmd.none )

                ( SubmitWarning, ( Just _, Nothing, Just _ ) ) ->
                    ( InProgress { m | error = Just "Missing field \"Stop\n                    Time\"" }, Cmd.none )

                ( SubmitWarning, ( Just _, Just _, Nothing ) ) ->
                    ( InProgress { m | error = Just "Missing field\n                    \"Description\"" }, Cmd.none )

                ( SubmitWarning, _ ) ->
                    ( InProgress { m | error = Just "Missing multiple\n                    fields" }, Cmd.none )

                ( InputStart s, _ ) ->
                    ( InProgress { m | start = String.toInt s }, Cmd.none )

                ( InputStop s, _ ) ->
                    ( InProgress { m | stop = String.toInt s }, Cmd.none )

                ( InputDescription s, _ ) ->
                    ( InProgress { m | description = Just s }, Cmd.none )

                ( _, _ ) ->
                    ( InProgress m, Cmd.none )


stringFromMaybeInt : Maybe Int -> String
stringFromMaybeInt num =
    case num of
        Just n ->
            String.fromInt n

        Nothing ->
            ""


view : Model -> Html Msg
view model =
    case model of
        InProgress f ->
            viewForm f

        Success RemoteData.Loading ->
            -- div [ class "center" ]
            --     [ h2 [ class "loading" ] [ text "Submitting warning to database..." ] ]
            text ""

        Success RemoteData.NotAsked ->
            text ""

        Success (RemoteData.Failure e) ->
            div [ class "center" ]
                [ h2 [ class "error" ] [ text "Internal Failure Loading Video" ] ]

        Success (RemoteData.Success _) ->
            div [ class "center" ]
                [ h2 [ class "success" ] [ text "Warning successfully submitted" ] ]


viewForm : Form -> Html Msg
viewForm model =
    div [ class "center", id "warning-form-container" ]
        [ form [ class "warning-form", onSubmit SubmitWarning ]
            [ viewError model.error
            , label [] [ text "Start Time" ]
            , viewInput
                "number"
                (stringFromMaybeInt model.start)
                InputStart
            , label [] [ text "Stop Time" ]
            , viewInput
                "number"
                (stringFromMaybeInt model.stop)
                InputStop
            , label [] [ text "Description" ]
            , textarea
                [ value (Maybe.withDefault "" model.description)
                , onInput InputDescription
                ]
                []
            , input [ class "submit", type_ "submit" ] [ text "Submit" ]
            ]
        ]


viewInput : String -> String -> (String -> msg) -> Html msg
viewInput t v toMsg =
    input [ type_ t, value v, onInput toMsg ] []


viewError : Maybe String -> Html Msg
viewError err =
    case err of
        Just e ->
            h2 [ class "error" ] [ text e ]

        Nothing ->
            div [] []


createWarning : Path -> Warning -> Cmd Msg
createWarning path warning =
    Http.post
        { url = url (path ++ [ "warnings" ]) []
        , expect =
            Http.expectWhatever (RemoteData.fromResult >> CreatedWarning)
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "start", Encode.int warning.start )
                    , ( "stop", Encode.int warning.stop )
                    , ( "description", Encode.string warning.description )
                    ]
                )
        }
