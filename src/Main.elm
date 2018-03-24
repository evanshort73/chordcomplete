port module Main exposing (..)

import Keyboard

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
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
  , topPitch : Int
  , dissonance : Float
  }

init : (Model, Cmd Msg)
init =
  ( { chord = Set.singleton 69
    , topPitch = 69
    , dissonance = 0
    }
  , requestDissonance [ 69 ]
  )

-- UPDATE

type Msg
  = AddInterval Int
  | SetDissonance Float

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    AddInterval interval ->
      let
        topPitch = model.topPitch + interval
      in let
        chord = Set.insert topPitch model.chord
      in
        ( { model
          | chord = chord
          , topPitch = topPitch
          }
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
    [ button [ onClick (AddInterval 3) ] [ text "add minor third" ]
    , button [ onClick (AddInterval 4) ] [ text "add major third" ]
    , text
        ( String.join
            " "
            ( List.concat
                [ List.map toString (Set.toList model.chord)
                , [ "(dissonance " ++ toString model.dissonance ++ ")" ]
                ]
            )
        )
    , Keyboard.view model.chord
    ]
