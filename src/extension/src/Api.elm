module Api exposing (Response(..), createVideo, getVideo)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Url exposing (Url)
import Url.Builder exposing (QueryParameter)
import Video exposing (Video)
import Warning exposing (Warning)


type alias Title =
    String


type alias Endpoint =
    String


type alias VId =
    String


type Response
    = GotWarnings (Result Http.Error (List Warning))
    | GotVideo (Result Http.Error Video)
    | CreatedVideo (Result Http.Error Endpoint)
    | CreatedWarning (Result Http.Error Endpoint)


getVideo : VId -> Cmd Response
getVideo vid =
    Http.get
        { url = url [ "videos" ] [ Url.Builder.string "vid" vid ]
        , expect = Http.expectJson GotVideo decodeVideo
        }


createVideo : VId -> Cmd Response
createVideo vid =
    Http.post
        { url = url [ "videos" ] []
        , body = Http.jsonBody (Encode.object [ ( "vid", Encode.string vid ) ])
        , expect = Http.expectStringResponse CreatedVideo decodeLocation
        }


url : List String -> List QueryParameter -> Endpoint
url path queryParams =
    Url.Builder.crossOrigin "http://localhost:5000" ("api" :: path) queryParams


decodeVideo : Decode.Decoder Video
decodeVideo =
    Decode.index 0 (Decode.map2 Video decodeTitle decodeVideoURI)


decodeTitle : Decode.Decoder Title
decodeTitle =
    Decode.field "video_title" Decode.string


decodeVideoURI : Decode.Decoder Title
decodeVideoURI =
    Decode.map (\id -> url ([ "videos" ] ++ [ String.fromInt id ]) [])
        (Decode.field "video_id" Decode.int)


decodeLocation : Http.Response body -> Result Http.Error Endpoint
decodeLocation response =
    case response of
        Http.BadUrl_ url_ ->
            Err (Http.BadUrl url_)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ metadata body ->
            Err (Http.BadStatus metadata.statusCode)

        Http.GoodStatus_ metadata body ->
            case Dict.get "location" metadata.headers of
                Just loc ->
                    Ok (url [ loc ] [])

                Nothing ->
                    Err (Http.BadBody "Missing Location")
