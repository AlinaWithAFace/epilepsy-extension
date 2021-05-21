module Api exposing (Path, url)

import Url exposing (Url)
import Url.Builder exposing (QueryParameter)


type alias Path =
    List String


url : Path -> List QueryParameter -> String
url path queryParams =
    Url.Builder.crossOrigin
        "http://cisc4667.cis.udel.edu"
        ("episense" :: "api" :: path)
        queryParams
