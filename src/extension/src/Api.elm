module Api exposing (url)

import Dict exposing (Dict)
import Url exposing (Url)
import Url.Builder exposing (QueryParameter)
import Warning exposing (Warning)


url : List String -> List QueryParameter -> String
url path queryParams =
    Url.Builder.crossOrigin "http://localhost:5000" ("api" :: path) queryParams

