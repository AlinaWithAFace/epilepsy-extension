module Api exposing (url)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Url exposing (Url)
import Url.Builder exposing (QueryParameter)
import Warning exposing (Warning)



type alias URI =
    String


-- getWarnings : URI -> Cmd Response
-- getWarnings path =
--     Http.get
--         { url = Url.Builder.crossOrigin path [ "warnings" ] []
--         , expect = Http.expectJson GotWarnings decodeWarnings
--         }


url : List String -> List QueryParameter -> URI
url path queryParams =
    Url.Builder.crossOrigin "http://localhost:5000" ("api" :: path) queryParams

-- decodeWarning : Decode.Decoder Warning
-- decodeWarning =
--     Decode.map3
--         Warning
--         (Decode.field "warning_start" Decode.int)
--         (Decode.field "warning_end" Decode.int)
--         (Decode.field "warning_description" Decode.string)


-- decodeWarnings : Decode.Decoder (List Warning)
-- decodeWarnings =
--     Decode.list decodeWarning
