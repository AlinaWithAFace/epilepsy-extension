module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, p, text)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Url
import Url.Parser exposing ((</>), (<?>))
import Url.Parser.Query
import Video exposing (Msg(..), Video, createVideo, getVideo)
import Warning exposing (Warning)


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type Page
    = EmptyPage


type alias Model =
    { video : WebData Video
    , page : Page
    }


init : String -> ( Model, Cmd Msg )
init videoURL =
    let
        youTubeIdParser =
            Url.Parser.s "watch" <?> Url.Parser.Query.string "v"

        parseYouTubeId urlString =
            case Url.fromString urlString of
                Just url ->
                    Maybe.withDefault Nothing (Url.Parser.parse youTubeIdParser url)

                Nothing ->
                    Nothing
    in
    case parseYouTubeId videoURL of
        Just id ->
            ( { video = RemoteData.Loading, page = EmptyPage }
            , Cmd.map VideoMsg (getVideo id)
            )

        Nothing ->
            ( { video = RemoteData.NotAsked, page = EmptyPage }, Cmd.none )


type Msg
    = VideoMsg Video.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( VideoMsg (GotVideo video), EmptyPage ) ->
            ( { model | video = video }, Cmd.none )

        ( VideoMsg (CreatedVideo (RemoteData.Success id)), EmptyPage ) ->
            ( { model | video = RemoteData.Loading }
            , Cmd.map VideoMsg (getVideo id)
            )

        ( VideoMsg (CreatedVideo (RemoteData.Failure e)), EmptyPage ) ->
            ( { model | video = RemoteData.NotAsked }, Cmd.none )

        ( VideoMsg (VideoNotFound id), EmptyPage ) ->
            ( { model | video = RemoteData.Loading }
            , Cmd.map VideoMsg (createVideo id)
            )

        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case ( model.page, model.video ) of
        ( _, RemoteData.Loading ) ->
            text "Loading Video Data"

        ( _, RemoteData.Failure e ) ->
            text "Internal Failure Loading Video"

        ( _, RemoteData.NotAsked ) ->
            text "Page does not appear to be a YouTube video"

        ( EmptyPage, RemoteData.Success video ) ->
            viewVideo video


viewVideo : Video -> Html Msg
viewVideo video =
    div []
        [ h1 [] [ text video.title ]
        ]
