module Keyboard exposing (view, Msg(..))

import Gradients

import Html exposing (Html)
import Html.Attributes exposing (attribute, style)
import Set exposing (Set)
import Svg exposing (Svg, svg, path, rect)
import Svg.Attributes exposing
  ( width, height, viewBox, d, fill, stroke, strokeWidth, strokeLinejoin
  , opacity
  )
import Svg.Events exposing (onClick)

type Msg
  = Select Int
  | Deselect Int

view : Set Int -> Html Msg
view chord =
  svg
    [ width "1248"
    , height "144"
    , viewBox "0 0 364 42"
    ]
    ( List.concat
        [ [ Gradients.keyboardGradients
          , rect
              [ width "100%"
              , height "100%"
              , fill "black"
              ]
              []
          ]
        , List.concatMap (drawKey chord) (List.range 0 87)
        ]
    )

drawKey : Set Int -> Int -> List (Svg Msg)
drawKey chord i =
  let
    pitch = i + 21
  in let
    selected = Set.member pitch chord
  in
    case i of
      0 -> drawWhiteKey pitch selected 0 0 0 1
      87 -> drawWhiteKey pitch selected (14 + 7 * 49) 0 0 0
      _ ->
        let
          remainder = (i - 6) % 12 -- octave starts at Eb
        in let
          quotient = (i - 6 - remainder) // 12
        in let
          x = toFloat (27 + quotient * 49 + remainder * 4)
        in
          case remainder of
            9 -> drawWhiteKey pitch selected x 0 0 3
            11 -> drawWhiteKey pitch selected x 0 1 1
            1 -> drawWhiteKey pitch selected x 0 3 0
            2 -> drawWhiteKey pitch selected x 0 0 3
            4 -> drawWhiteKey pitch selected x 0 1 2
            6 -> drawWhiteKey pitch selected x 0 2 1
            8 -> drawWhiteKey pitch selected x 0 3 0
            _ -> drawBlackKey pitch selected x 0

drawWhiteKey :
  Int -> Bool -> Float -> Float -> Int -> Int -> List (Svg Msg)
drawWhiteKey pitch selected x y lThin rThin =
  let
    dAttribute =
      dHelp
        [ [ "M", toString (x + 0.25)
          , ",", toString (y + 0.25)
          ]
        , if lThin == 0 then
            [ " v", toString (whiteLength - 1.25)
            ]
          else
            [ " v", toString blackLength
            , " h", toString -lThin
            , " v", toString (whiteLength - blackLength - 1.25)
            ]
        , [ " a0.75,0.75 90 0 0 0.75,0.75"
          , " h5"
          , " a0.75,0.75 90 0 0 0.75,-0.75"
          ]
        , if rThin == 0 then
            [ " v", toString -(whiteLength - 1.25)
            ]
          else
            [ " v", toString -(whiteLength - blackLength - 1.25)
            , " h", toString -rThin
            , " v", toString -blackLength
            ]
        ]
  in
    List.concat
      [ [ path
            [ fill (if selected then "#99ccff" else "white")
            , attribute "tabindex" "0"
            , style [ ( "cursor", "pointer" ) ]
            , onClick ((if selected then Deselect else Select) pitch)
            , dAttribute
            ]
            []
        ]
      , if selected then
          [ path
              [ stroke "#3399ff"
              , fill "none"
              , strokeWidth "0.5"
              , strokeLinejoin "round"
              , style [ ( "pointer-events", "none" ) ]
              , dAttribute
              ]
              []
          ]
        else
          []
      ]

drawBlackKey : Int -> Bool -> Float -> Float -> List (Svg Msg)
drawBlackKey pitch selected x y =
  let
    dAttribute =
      dHelp
        [ [ "M", toString (x + 0.25)
          , ",", toString (y + 0.25)
          , " v", toString (blackLength - 0.5)
          , " h3.5 v", toString -(blackLength - 0.5)
          ]
        ]
  in
    List.concat
      [ [ path
            [ fill (if selected then "#204080" else "black")
            , attribute "tabindex" "0"
            , style [ ( "cursor", "pointer" ) ]
            , onClick ((if selected then Deselect else Select) pitch)
            , dAttribute
            ]
            []
        , path
            [ fill "white"
            , opacity "0.46"
            , style [ ( "pointer-events", "none" ) ]
            , dHelp
                [ [ "M", toString (x + 0.25 + 3.5)
                  , ",", toString (y + blackLength - 0.25)
                  , " c0,", toString -(gravestoneHeight / 0.75)
                  , " -3.5,", toString -(gravestoneHeight / 0.75)
                  , " -3.5,0"
                  ]
                ]
            ]
            []
        , path
            [ fill "url(#blackKey)"
            , opacity "0.67"
            , style [ ( "pointer-events", "none" ) ]
            , dHelp
                [ [ "M", toString (x + 0.25)
                  , ",", toString (y + 0.25)
                  , " v", toString (blackLength - 0.5)
                  , " c0,", toString -(gravestoneHeight * 2 / 3)
                  , " 0.875,", toString -gravestoneHeight
                  , " 1.75,", toString -gravestoneHeight
                  , " c-0.75,0 -1.5,", toString -(deadEndHeight / 3)
                  , " -1.5", toString -deadEndHeight
                  , " v"
                  , toString
                      -(blackLength - gravestoneHeight - deadEndHeight - 0.5)
                  ]
                ]
            ]
            []
        , path
            [ fill "url(#blackKey)"
            , opacity "0.46"
            , style [ ( "pointer-events", "none" ) ]
            , dHelp
                [ [ "M", toString (x + 0.25 + 3.5)
                  , ",", toString (y + blackLength - 0.25)
                  , " c0,", toString -(rightGlint * gravestoneHeight / 0.75)
                  , " ", toString -(rightGlint * rightGlint * 3.5)
                  , ",", toString -(rightGlint * (2 - rightGlint) * gravestoneHeight / 0.75)
                  , " ", toString -(rightGlint * rightGlint * (3 - 2 * rightGlint) * 3.5)
                  , ",", toString -(3 * rightGlint * (1 - rightGlint) * gravestoneHeight / 0.75)
                  , " V", toString (y + 0.25)
                  , " h", toString (rightGlint * rightGlint * (3 - 2 * rightGlint) * 3.5)
                  ]
                ]
            ]
            []
        , path
            [ fill "url(#blackKey)"
            , opacity "0.28"
            , style [ ( "pointer-events", "none" ) ]
            , dHelp
                [ [ "M", toString (x + 0.5)
                  , ",", toString (y + 0.25)
                  , " v", toString (blackLength - gravestoneHeight - deadEndHeight - 0.5)
                  , " c0,", toString (deadEndHeight / 0.75)
                  , " 3,", toString (deadEndHeight / 0.75)
                  , " 3,0"
                  , "v", toString -(blackLength - gravestoneHeight - deadEndHeight - 0.5)
                  ]
                ]
            ]
            []
        ]
      , if selected then
          [ path
              [ stroke "#3399ff"
              , fill "none"
              , strokeWidth "0.5"
              , strokeLinejoin "round"
              , style [ ( "pointer-events", "none" ) ]
              , dAttribute
              ]
              []
          ]
        else
          []
      ]

whiteLength : Float
whiteLength = 42

blackLength : Float
blackLength = 27

gravestoneHeight : Float
gravestoneHeight = 1.55

deadEndHeight : Float
deadEndHeight = 0.95

rightGlint : Float
rightGlint = 0.12

dHelp : List (List String) -> Svg.Attribute msg
dHelp = d << String.concat << List.concat
