port module Main exposing (..)

import Guide exposing (Guide)
import Keyboard

import Html exposing (Html, button, div, text)
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


-- SUBSCRIPTIONS

port requestGuide : List Int -> Cmd msg
port receiveGuide : (Decode.Value -> msg) -> Sub msg

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ Html.map KeyboardMsg (Keyboard.view model.chord)
    , div []
        [ text (toString model.guide.dissonance)
        ]
    ]
