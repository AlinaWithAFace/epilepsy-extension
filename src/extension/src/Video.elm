module Video exposing (Msg(..), Video, createVideo, getVideo, parseYouTubeId)

import Api exposing (Path, url)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData exposing (WebData)
import Url exposing (Url)
import Url.Builder
import Url.Parser as Parser exposing ((<?>))
import Url.Parser.Query as Query


type alias Video =
    { title : String
    , path : Path
    }


type alias YouTubeId =
    String


urlParseYouTubeId : Url -> Maybe String
urlParseYouTubeId str =
    Maybe.withDefault Nothing <|
        Parser.parse (Parser.s "watch" <?> Query.string "v") str


parseYouTubeId : String -> Maybe String
parseYouTubeId urlString =
    Url.fromString urlString |> Maybe.andThen urlParseYouTubeId


type Msg
    = GotVideo (WebData Video)
    | CreatedVideo (WebData YouTubeId)
    | VideoNotFound YouTubeId


getVideoMsg : YouTubeId -> Result Http.Error Video -> Msg
getVideoMsg id result =
    case result of
        Err (Http.BadStatus 404) ->
            VideoNotFound id

        _ ->
            GotVideo (RemoteData.fromResult result)


getVideo : YouTubeId -> Cmd Msg
getVideo id =
    Http.get
        { url = url [ "videos" ] [ Url.Builder.string "vid" id ]
        , expect = Http.expectJson (getVideoMsg id) decodeVideo
        }


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


decodeVideo : Decode.Decoder Video
decodeVideo =
    Decode.index 0 (Decode.map2 Video decodeTitle decodePath)


decodeTitle : Decode.Decoder String
decodeTitle =
    Decode.field "video_title" Decode.string


decodePath : Decode.Decoder Path
decodePath =
    Decode.map (\id -> [ "videos" ] ++ [ String.fromInt id ])
        (Decode.field "video_id" Decode.int)
