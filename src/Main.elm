port module Main exposing (..)

import Keyboard

import Html exposing (Html, button, div, text)
import Set exposing (Set)

main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = always (receiveDissonance SetDissonance)
    }

-- MODEL

type alias Model =
  { chord : Set Int
  , dissonance : Float
  }

init : (Model, Cmd Msg)
init =
  ( { chord = Set.empty
    , dissonance = 0
    }
  , requestDissonance []
  )

-- UPDATE

type Msg
  = KeyboardMsg Keyboard.Msg
  | SetDissonance Float

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    KeyboardMsg (Keyboard.Select pitch) ->
      let
        chord = Set.insert pitch model.chord
      in
        ( { model | chord = chord }
        , requestDissonance (Set.toList chord)
        )

    KeyboardMsg (Keyboard.Deselect pitch) ->
      let
        chord = Set.remove pitch model.chord
      in
        ( { model | chord = chord }
        , requestDissonance (Set.toList chord)
        )

    SetDissonance dissonance ->
      ( { model
        | dissonance = dissonance
        }
      , Cmd.none
      )


-- SUBSCRIPTIONS

port requestDissonance : List Int -> Cmd msg
port receiveDissonance : (Float -> msg) -> Sub msg

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ Html.map KeyboardMsg (Keyboard.view model.chord)
    , div []
        [ text (toString model.dissonance)
        ]
    ]
