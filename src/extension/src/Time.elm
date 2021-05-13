module Time exposing (Time, fromInt, fromString, toInt, toString)

import Parser
    exposing
        ( (|.)
        , (|=)
        , chompIf
        , chompWhile
        , getChompedString
        , int
        , run
        , spaces
        , succeed
        , symbol
        )


type alias Time =
    { minutes : Int
    , seconds : Int
    }


fromInt : Int -> Time
fromInt i =
    { minutes = modBy 60 i
    , seconds = i // 60
    }


fromString : String -> Maybe Time
fromString str =
    let
        digit =
            getChompedString <|
                succeed ()
                    |. chompIf Char.isDigit

        seconds =
            succeed (++)
                |= digit
                |= digit

        minutes =
            getChompedString <|
                succeed ()
                    |. chompWhile Char.isDigit

        time min sec =
            case (String.toInt min, String.toInt sec) of
                (Just m, Just s) ->
                    if s < 60 then
                        Just { minutes = m, seconds = s }
                    else
                        Nothing
                _ -> Nothing

        parser =
            succeed time
                |. spaces
                |= minutes
                |. symbol ":"
                |= seconds
                |. spaces
    in
    case run parser str of
        Ok (Just t) ->
            Just t

        _ ->
            Nothing


toString : Time -> String
toString t =
    let
        seconds =
            if t.seconds < 10 then
                "0" ++ String.fromInt t.seconds
            else
                String.fromInt t.seconds
    in
    String.fromInt t.minutes ++ ":" ++ seconds


toInt : Time -> Int
toInt t =
    t.minutes * 60 + t.seconds
