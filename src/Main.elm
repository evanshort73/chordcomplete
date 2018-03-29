port module Main exposing (..)

import AudioChange exposing (AudioChange(..))
import Guide exposing (Guide)
import Keyboard

import Html exposing (Html, div, text)
import Json.Decode as Decode
import Set exposing (Set)

main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = always (receiveGuide SetGuide)
    }

-- MODEL

type alias Model =
  { chord : Set Int
  , guide : Guide
  }

init : (Model, Cmd Msg)
init =
  ( { chord = Set.empty
    , guide =
        { dissonance = 0
        , deltas = List.repeat 88 0
        }
    }
  , requestGuide []
  )

-- UPDATE

type Msg
  = KeyboardMsg Keyboard.Msg
  | SetGuide Decode.Value

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    KeyboardMsg (Keyboard.Select pitch) ->
      let
        chord = Set.insert pitch model.chord
      in
        ( { model | chord = chord }
        , Cmd.batch
            [ requestGuide (Set.toList chord)
            , AudioChange.perform
                [ AddNote { delay = 0, f = pitchFrequency pitch }
                ]
            ]
        )

    KeyboardMsg (Keyboard.Deselect pitch) ->
      let
        chord = Set.remove pitch model.chord
      in
        ( { model | chord = chord }
        , Cmd.batch
            [ requestGuide (Set.toList chord)
            , AudioChange.perform
                [ AddNote { delay = 0, f = pitchFrequency pitch }
                , MuteAllNotes 0.03
                ]
            ]
        )

    SetGuide value ->
      ( case Decode.decodeValue Guide.decoder value of
          Ok guide ->
            { model | guide = guide }
          Err _ ->
            model
      , Cmd.none
      )

pitchFrequency : Int -> Float
pitchFrequency pitch =
  440 * 2 ^ (toFloat (pitch - 69) / 12)

-- SUBSCRIPTIONS

port requestGuide : List Int -> Cmd msg
port receiveGuide : (Decode.Value -> msg) -> Sub msg

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ Html.map KeyboardMsg (Keyboard.view model.chord model.guide.deltas)
    , div []
        [ text (toString model.guide.dissonance)
        ]
    ]
