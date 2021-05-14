module Video exposing (Video, YouTubeId)

import Api exposing (Path)


type alias Video =
    { youTubeId : YouTubeId
    , path : Path
    }

type alias YouTubeId =
    String
