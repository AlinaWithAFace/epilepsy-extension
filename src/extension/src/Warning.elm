module Warning exposing(Warning)

import Time exposing (Time)
import Api exposing (Path, url)

type alias Warning =
  { start : Time
  , stop : Time
  , description : String
  }
