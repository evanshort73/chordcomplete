port module Main exposing (..)

import AudioChange exposing (AudioChange(..))
import Guide exposing (Guide)
import Keyboard

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
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
  | PlayNote

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    KeyboardMsg (Keyboard.Select pitch) ->
      let
        chord = Set.insert pitch model.chord
      in
        ( { model | chord = chord }
        , requestGuide (Set.toList chord)
        )

    KeyboardMsg (Keyboard.Deselect pitch) ->
      let
        chord = Set.remove pitch model.chord
      in
        ( { model | chord = chord }
        , requestGuide (Set.toList chord)
        )

    SetGuide value ->
      ( case Decode.decodeValue Guide.decoder value of
          Ok guide ->
            { model | guide = guide }
          Err _ ->
            model
      , Cmd.none
      )

    PlayNote ->
      ( model
      , AudioChange.perform [ AddNote { delay = 0, f = 440 } ]
      )

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
    , button
        [ onClick PlayNote
        ]
        [ text "Play a note"
        ]
    ]
