module ScreeningStatus exposing (ScreeningStatus(..), fromString)

type ScreeningStatus
    = NotStarted
    | Started
    | Completed

fromString : String -> Maybe ScreeningStatus
fromString s =
    case s of
        "NOT STARTED" -> Just NotStarted
        "STARTED" -> Just Started
        "COMPLETED" -> Just Completed
        _ -> Nothing
