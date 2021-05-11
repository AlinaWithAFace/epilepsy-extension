module Main exposing (main)

import Api
import Browser
import Dict exposing (Dict)
import Html exposing (Html, h1, pre, text)
import Http
import Json.Decode as D
import Json.Encode as E
import Video exposing (Video)


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type Model
    = Failure Http.Error
    | Loading
    | Success String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Api.getVideo "5qap5aO4i9A"
    )


type alias Msg =
    Api.Response


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Api.GotVideo (Err (Http.BadStatus 404)) ->
            ( Loading, Api.createVideo "5qap5aO4i9A" )

        Api.GotVideo (Ok video) ->
            ( Success video.title, Cmd.none )

        Api.CreatedVideo (Ok endpoint) ->
            ( Loading, Api.getVideo "5qap5aO4i9A" )

        _ ->
            ( Loading, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model of
        Failure e ->
            text (Debug.toString e)

        Loading ->
            text "Loading"

        Success fullText ->
            pre [] [ h1 [] [ text fullText ] ]
