module Error exposing (toString, view)

import Html exposing (Html, div, h2, text)
import Html.Attributes exposing (class)
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
                "Received Status \"" ++ String.fromInt i ++ "\""

            Http.BadBody _ ->
                "Unexpected Response Body"


view : String -> Html msg
view e =
    h2 [ class "error" ] [ text e ]
