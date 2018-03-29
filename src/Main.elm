port module Main exposing (..)

import AudioChange exposing (AudioChange(..), Note)
import Guide exposing (Guide)
import Harp exposing (Pos)
import Keyboard

import Html exposing (Html, div, text)
import Json.Decode as Decode exposing (Decoder)
import Set exposing (Set)

main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { chord : Set Int
  , guide : Guide
  , dragPos : Maybe Pos
  }

init : (Model, Cmd Msg)
init =
  ( { chord = Set.empty
    , guide =
        { dissonance = 0
        , deltas = List.repeat 88 0
        }
    , dragPos = Nothing
    }
  , requestGuide []
  )

-- UPDATE

type Msg
  = KeyboardMsg Keyboard.Msg
  | HarpMsg Harp.Msg
  | MouseMove Decode.Value
  | MouseUp ()
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

    HarpMsg (Harp.MouseDown pos) ->
      ( { model | dragPos = Just pos }
      , Cmd.none
      )

    MouseMove posJson ->
      case model.dragPos of
        Nothing ->
          ( model, Cmd.none )
        Just oldPos ->
          case Decode.decodeValue posDecoder posJson of
            Err _ ->
              ( model, Cmd.none )
            Ok newPos ->
              ( { model | dragPos = Just newPos }
              , AudioChange.perform
                  ( List.map
                      (AddNote << Note 0 << pitchFrequency)
                      ( Set.toList
                          (Harp.strum model.chord oldPos newPos)
                      )
                  )
              )

    MouseUp _ ->
      ( { model | dragPos = Nothing }
      , Cmd.none
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

posDecoder : Decoder Pos
posDecoder =
  Decode.map2
    Pos
    (Decode.field "x" Decode.float)
    (Decode.field "y" Decode.float)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  if model.dragPos == Nothing then
    receiveGuide SetGuide
  else
    Sub.batch
      [ receiveGuide SetGuide
      , mouseMove MouseMove
      , mouseUp MouseUp
      ]

port requestGuide : List Int -> Cmd msg
port receiveGuide : (Decode.Value -> msg) -> Sub msg
port mouseMove : (Decode.Value -> msg) -> Sub msg
port mouseUp : (() -> msg) -> Sub msg

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ Html.map KeyboardMsg (Keyboard.view model.chord model.guide.deltas)
    , Html.map HarpMsg (Harp.view model.chord)
    , div []
        [ text (toString model.guide.dissonance)
        ]
    ]
