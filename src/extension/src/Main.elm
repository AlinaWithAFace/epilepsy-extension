module Main exposing (main)

import Api exposing (Path, url)
import Browser
import Error
import Http
import Html exposing (Html, button, div, header, menu, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Page.ListWarnings as ListWarnings
import Page.NewWarning as NewWarning
import RemoteData exposing (WebData)
import Json.Decode as Decode
import Json.Encode as Encode
import Url exposing (Url)
import Url.Builder
import Url.Parser as Parser exposing ((<?>))
import Url.Parser.Query as Query
import Video exposing (Video, YouTubeId)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Page
    = EmptyPage
    | ListPage ListWarnings.Model
    | NewPage NewWarning.Model


type alias Model =
    { video : WebData Video
    , page : Page
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case ( model.page, model.video ) of
        ( _, RemoteData.Loading ) ->
            header [] [ div [ class "center" ] [ text "" ] ]

        ( _, RemoteData.Failure e ) ->
            header []
                [ div [ class "center" ] [ Error.view (Error.toString e) ] ]

        ( _, RemoteData.NotAsked ) ->
            header []
                [ div
                    [ class "center" ]
                    [ Error.view "Page does not appear to be a YouTube video" ]
                ]

        ( EmptyPage, RemoteData.Success video ) ->
            div []
                [ viewVideoMenu video ]

        ( ListPage pageModel, RemoteData.Success video ) ->
            div []
                [ viewVideoMenu video
                , Html.map ListPageMsg (ListWarnings.view pageModel)
                ]

        ( NewPage pageModel, RemoteData.Success video ) ->
            div []
                [ viewVideoMenu video
                , Html.map NewPageMsg (NewWarning.view pageModel)
                ]


viewVideoMenu : Video -> Html Msg
viewVideoMenu video =
    header []
        [ menu []
            [ button
                [ onClick (ClickList video.path) ]
                [ text "Show Warnings" ]
            , button
                [ onClick (ClickNew video.path) ]
                [ text "Create New Warning" ]
            ]
        ]



-- INIT


init : String -> ( Model, Cmd Msg )
init videoURL =
    case parseYouTubeId videoURL of
        Just id ->
            ( { video = RemoteData.Loading, page = EmptyPage }
            , getVideo id
            )

        Nothing ->
            ( { video = RemoteData.NotAsked, page = EmptyPage }, Cmd.none )


urlParseYouTubeId : Url -> Maybe String
urlParseYouTubeId str =
    Maybe.withDefault Nothing <|
        Parser.parse (Parser.s "watch" <?> Query.string "v") str


parseYouTubeId : String -> Maybe String
parseYouTubeId urlString =
    Url.fromString urlString |> Maybe.andThen urlParseYouTubeId



-- UPDATE


type Msg
    = GotVideo (WebData Video)
    | CreatedVideo (WebData YouTubeId)
    | VideoNotFound YouTubeId
    | ListPageMsg ListWarnings.Msg
    | NewPageMsg NewWarning.Msg
    | ClickList Path
    | ClickNew Path


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( GotVideo video, EmptyPage ) ->
            ( { model | video = video }, Cmd.none )

        ( CreatedVideo (RemoteData.Success id), EmptyPage ) ->
            ( { model | video = RemoteData.Loading }
            , getVideo id
            )

        ( CreatedVideo (RemoteData.Failure e), EmptyPage ) ->
            ( { model | video = RemoteData.NotAsked }, Cmd.none )

        ( VideoNotFound id, EmptyPage ) ->
            ( { model | video = RemoteData.Loading }
            , createVideo id
            )

        ( ListPageMsg subMsg, ListPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ListWarnings.update subMsg pageModel
            in
            ( { model | page = ListPage updatedPageModel }
            , Cmd.map ListPageMsg updatedCmd
            )

        ( ClickList path, _ ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ListWarnings.init path
            in
            ( { model | page = ListPage updatedPageModel }
            , Cmd.map ListPageMsg updatedCmd
            )

        ( NewPageMsg subMsg, NewPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewWarning.update subMsg pageModel
            in
            ( { model | page = NewPage updatedPageModel }
            , Cmd.map NewPageMsg updatedCmd
            )

        ( ClickNew path, _ ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewWarning.init path
            in
            ( { model | page = NewPage updatedPageModel }
            , Cmd.map NewPageMsg updatedCmd
            )

        _ ->
            ( model, Cmd.none )


resultToMsg : YouTubeId -> Result Http.Error Video -> Msg
resultToMsg id result =
    case result of
        Err (Http.BadStatus 404) ->
            VideoNotFound id

        _ ->
            GotVideo (RemoteData.fromResult result)


getVideo : YouTubeId -> Cmd Msg
getVideo id =
    Http.get
        { url = url [ "videos" ] [ Url.Builder.string "vid" id ]
        , expect = Http.expectJson (resultToMsg id) decodeVideo
        }


decodeVideo : Decode.Decoder Video
decodeVideo =
    Decode.index 0 (Decode.map2 Video decodeYouTubeId decodePath)


decodeYouTubeId : Decode.Decoder YouTubeId
decodeYouTubeId =
    Decode.field "video_vid" Decode.string


decodePath : Decode.Decoder Path
decodePath =
    Decode.map (\id -> [ "videos" ] ++ [ String.fromInt id ])
        (Decode.field "video_id" Decode.int)


createVideo : YouTubeId -> Cmd Msg
createVideo id =
    Http.post
        { url = url [ "videos" ] []
        , body =
            Http.jsonBody (Encode.object [ ( "vid", Encode.string id ) ])
        , expect =
            Http.expectWhatever
                (Result.map (\_ -> id) >> RemoteData.fromResult >> CreatedVideo)
        }
