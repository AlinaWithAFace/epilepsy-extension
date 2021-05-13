module Error exposing (toString)

import Http


toString : Http.Error -> String
toString err =
    (++) "HTTP Error: " <|
        case err of
            Http.BadUrl s ->
                "Illegal Url \"" ++ s ++ "\""
            Http.Timeout ->
                "Timeout"
            Http.NetworkError ->
                "Failed to Connect to Server"
            Http.BadStatus i ->
                "Received Status \"" ++ String.fromInt i++ "\""
            Http.BadBody _ ->
                "Unexpected Response Body"
