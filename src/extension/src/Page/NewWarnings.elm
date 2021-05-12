module NewWarning exposing (Msg(..), init)

import Api exposing (URI, url)
import Warnings


type alias Model =
    { uri : String
    , start : Maybe Int
    , stop : Maybe Int
    , description : Maybe String
    }


init : URI -> ( Model, Cmd Msg )
init uri =
    ( { uri = uri
      , start = Nothing
      , stop = Nothing
      , description = Nothing
      }
    , Cmd.none
    )


type Msg
    = CreatedWarning (WebData ())
    | SubmitWarning
