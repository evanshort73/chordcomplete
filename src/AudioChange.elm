port module AudioChange exposing (AudioChange(..), Note, perform)

import Json.Encode as Encode

type AudioChange
  = AddNote Note
  | MuteAllNotes Float

type alias Note =
  { delay : Float
  , f : Float
  }

perform : List AudioChange -> Cmd msg
perform = changeAudio << List.map toJson

port changeAudio : List Encode.Value -> Cmd msg

toJson : AudioChange -> Encode.Value
toJson change =
  case change of
    AddNote { delay, f } ->
      Encode.object
        [ ( "type", Encode.string "note" )
        , ( "delay", Encode.float delay )
        , ( "f", Encode.float f )
        ]
    MuteAllNotes delay ->
      Encode.object
        [ ( "type", Encode.string "mute" )
        , ( "delay", Encode.float delay )
        ]
