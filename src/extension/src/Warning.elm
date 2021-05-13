module Warning exposing(Warning)

import Time exposing (Time)

type alias Warning =
  { start : Time
  , stop : Time
  , description : String
  }
