module Page.NewWarning exposing (Model, Msg(..), init, update, view)

import Api exposing (Path, url)
import Html exposing (Html, div, form, h2, input, label, text, textarea)
import Html.Attributes
    exposing
        ( class
        , id
        , pattern
        , placeholder
        , type_
        , value
        )
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Encode as Encode
import RemoteData exposing (WebData)
import Time exposing (Time)
import Warning exposing (Warning)


type alias Form =
    { path : Path
    , start : String
    , stop : String
    , description : String
    , error : Maybe String
    }


type Model
    = InProgress Form
    | Success (WebData ())


init : Path -> ( Model, Cmd Msg )
init path =
    ( InProgress
        { path = path
        , start = ""
        , stop = ""
        , description = ""
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

        (SubmitWarning, InProgress form) ->
            case ( Time.fromString form.start, Time.fromString form.stop ) of
                ( Just start, Just stop ) ->
                    ( Success RemoteData.Loading
                    , createWarning
                        form.path
                        { start = start
                        , stop = stop
                        , description = form.description
                        }
                    )

                ( Nothing, Nothing ) ->
                    ( InProgress
                        { form | error = Just "Failed to parse times" }
                    , Cmd.none
                    )

                ( Nothing, _ ) ->
                    ( InProgress
                        { form | error = Just "Failed to parse start time" }
                    , Cmd.none
                    )

                ( _, Nothing ) ->
                    ( InProgress
                        { form | error = Just "Failed to parse stop time" }
                    , Cmd.none
                    )

        ( InputStart s, InProgress form ) ->
            ( InProgress
                { form | start = s }
            , Cmd.none
            )
        ( InputStop s, InProgress form ) ->
            ( InProgress
                { form | stop = s }
            , Cmd.none
            )

        ( InputDescription s, InProgress form ) ->
            ( InProgress { form | description = s }, Cmd.none )

        _ ->
            ( model, Cmd.none )


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
            , timeInput
                model.start
                InputStart
            , label [] [ text "Stop Time" ]
            , timeInput
                 model.stop
                InputStop
            , label [] [ text "Description" ]
            , textarea
                [ value model.description
                , onInput InputDescription
                , placeholder "Description of the potential photosensitivity trigger"
                ]
                []
            , input [ class "submit", type_ "submit" ] [ text "Submit" ]
            ]
        ]


timeInput : String -> (String -> msg) -> Html msg
timeInput v toMsg =
    input
        [ pattern "[0-9]*:[0-5][0-9]"
        , placeholder "mm:ss"
        , type_ "text"
        , value v
        , onInput toMsg
        ]
        []


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
                    [ ( "start", Encode.int (Time.toInt warning.start) )
                    , ( "stop", Encode.int (Time.toInt warning.stop) )
                    , ( "description", Encode.string warning.description )
                    ]
                )
        }
