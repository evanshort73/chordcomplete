module Guide exposing (Guide, decoder)

import Json.Decode as Decode exposing (Decoder)

type alias Guide =
  { dissonance : Float
  , deltas : List Float
  }

decoder : Decoder Guide
decoder =
  Decode.map2
    Guide
    (Decode.field "dissonance" Decode.float)
    (Decode.field "deltas" (Decode.list Decode.float))
