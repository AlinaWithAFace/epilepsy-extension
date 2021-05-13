module Api exposing (url, Path)

import Url exposing (Url)
import Url.Builder exposing (QueryParameter)

type alias Path = List String

url : Path -> List QueryParameter -> String
url path queryParams =
    Url.Builder.crossOrigin "http://localhost:5000" ("api" :: path) queryParams
