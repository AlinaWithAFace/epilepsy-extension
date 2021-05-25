module Warning exposing(Warning, Source(..))

import Time exposing (Time)

type Source
    = Automated
    | UserGenerated

type alias Warning =
  { start : Time
  , stop : Time
  , description : String
  , source : Source
  }
