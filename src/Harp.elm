module Harp exposing (view, Msg(..), Pos, strum)

import Html exposing (Html)
import Html.Events exposing (onMouseUp, onWithOptions)
import Html.Attributes exposing (id)
import Json.Decode as Decode exposing (Decoder)
import Set exposing (Set)
import Svg exposing (Svg, svg, rect, line)
import Svg.Attributes exposing
  (width, height, viewBox, fill, stroke, x1, y1, x2, y2)

type Msg
  = MouseDown Pos

type alias Pos =
  { x : Float
  , y : Float
  }

type alias IntPos =
  { x : Int
  , y : Int
  }

view : Set Int -> Html Msg
view chord =
  svg
    [ width "1248"
    , height "312"
    , viewBox "0 0 364 91"
    , id "harp"
    , onWithOptions
        "mousedown"
        { stopPropagation = False, preventDefault = True }
        ( Decode.map
            (MouseDown << normalizePos)
            primaryButtonOffsetDecoder
        )
    ]
    ( List.concat
        [ [ rect
              [ width "100%"
              , height "100%"
              , fill "lightblue"
              ]
              []
          ]
        , List.map drawString (Set.toList chord)
        ]
    )

strum : Set Int -> Pos -> Pos -> Set Int
strum chord start end =
  let
    ( high, low ) =
      if end.y < start.y then
        ( end, start )
      else
        ( start, end )
  in
    if high.y >= 1 || low.y <= 0 then
      Set.empty
    else
      let
        highX =
          if high.y < 0 then
            (high.x * low.y - low.x * high.y) /
              (low.y - high.y)
          else
            high.x
      in let
        lowX =
          if low.y > 1 then
            (high.x * (low.y - 1) - low.x * (high.y - 1)) /
              (low.y - high.y)
          else
            low.x
      in
        Set.filter
          (pitchInXRange (min highX lowX) (max highX lowX))
          chord

pitchInXRange : Float -> Float -> Int -> Bool
pitchInXRange start stop pitch =
  let x = pitchX pitch / 364 in
    x >= start && x < stop

drawString : Int -> Svg msg
drawString pitch =
  let x = pitchX pitch in
    line
      [ stroke "black"
      , x1 (toString x)
      , y1 "0"
      , x2 (toString x)
      , y2 "312"
      ]
      []

pitchX : Int -> Float
pitchX pitch =
  let
    key = pitch - 21
  in let
    remainder = (key - 6) % 12 -- octave starts at Eb
  in let
    quotient = (key - 6 - remainder) // 12
  in
    if remainder < 11 then
      29 + 49 * toFloat quotient + 4 * toFloat remainder
    else
      24.5 + 49 + 49 * toFloat quotient

normalizePos : IntPos -> Pos
normalizePos intPos =
  { x = toFloat intPos.x / 364
  , y = toFloat intPos.y / 91
  }

primaryButtonOffsetDecoder : Decoder IntPos
primaryButtonOffsetDecoder =
  Decode.andThen
    (decodeIfZero offsetDecoder)
    (Decode.field "button" Decode.int)

decodeIfZero : Decoder a -> Int -> Decoder a
decodeIfZero decoder value =
  if value == 0 then decoder else Decode.fail "ignoring nonzero value"

offsetDecoder : Decoder IntPos
offsetDecoder =
  Decode.map2
    IntPos
    (Decode.field "offsetX" Decode.int)
    (Decode.field "offsetY" Decode.int)
