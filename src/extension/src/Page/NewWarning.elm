module Page.NewWarning exposing (Model, Msg(..), init, update, view)

import Api exposing (Path, url)
import Error
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


type alias Model =
    { path : Path
    , start : String
    , stop : String
    , description : String
    , error : Maybe String
    , response : WebData ()
    }


view : Model -> Html Msg
view model =
    case model.response of
        RemoteData.Loading ->
            div [ class "center" ]
                [ h2 [ class "loading" ] [ text "Loading..." ]
                ]

        RemoteData.NotAsked ->
            viewForm model

        RemoteData.Failure e ->
            div [ class "center" ]
                [ Error.view (Error.toString e) ]

        RemoteData.Success _ ->
            div [ class "center" ]
                [ h2 [ class "success" ]
                    [ text "Warning successfully submitted" ]
                ]


viewForm : Model -> Html Msg
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
                , placeholder
                    "Description of why the video segment might be dangerous"
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
    Maybe.withDefault (div [] []) <|
        Maybe.map Error.view err


init : Path -> ( Model, Cmd Msg )
init path =
    ( { path = path
      , start = ""
      , stop = ""
      , description = ""
      , error = Nothing
      , response = RemoteData.NotAsked
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
    case ( msg, model.response ) of
        ( CreatedWarning (RemoteData.Failure (Http.BadStatus 400)), _ ) ->
            ( { model
                | response = RemoteData.NotAsked
                , error = Just "Invalid start and/or end time(s)"
              }
            , Cmd.none
            )

        ( CreatedWarning w, _ ) ->
            ( { model | response = w }, Cmd.none )

        ( SubmitWarning, RemoteData.NotAsked ) ->
            case ( Time.fromString model.start, Time.fromString model.stop ) of
                ( Just start, Just stop ) ->
                    ( { model | response = RemoteData.Loading }
                    , createWarning
                        model.path
                        { start = start
                        , stop = stop
                        , description = model.description
                        }
                    )

                ( Nothing, Nothing ) ->
                    ( { model | error = Just "Missing start and stop times" }
                    , Cmd.none
                    )

                ( Nothing, _ ) ->
                    ( { model | error = Just "Missing start time" }
                    , Cmd.none
                    )

                ( _, Nothing ) ->
                    ( { model | error = Just "Missing stop time" }
                    , Cmd.none
                    )

        ( InputStart s, RemoteData.NotAsked ) ->
            ( { model | start = s }, Cmd.none )

        ( InputStop s, RemoteData.NotAsked ) ->
            ( { model | stop = s }, Cmd.none )

        ( InputDescription s, RemoteData.NotAsked ) ->
            ( { model | description = s }, Cmd.none )

        _ ->
            ( model, Cmd.none )


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
