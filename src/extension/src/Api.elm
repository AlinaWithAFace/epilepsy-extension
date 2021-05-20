module Api exposing (Path, url)

import Url exposing (Url)
import Url.Builder exposing (QueryParameter)


type alias Path =
    List String


url : Path -> List QueryParameter -> String
url path queryParams =
    Url.Builder.crossOrigin
        "http://107.23.130.40:8080"
        ("api" :: path)
        queryParams
