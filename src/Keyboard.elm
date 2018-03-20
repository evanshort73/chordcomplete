module Keyboard exposing (view)

import Gradients

import Html exposing (Html)
import Html.Attributes exposing (attribute, style)
import Svg exposing (Svg, svg, path, rect)
import Svg.Attributes exposing
  (width, height, viewBox, d, fill, opacity)

view : Html msg
view =
  svg
    [ width "700"
    , height "600"
    , viewBox "0 0 49 42"
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
        , List.concat
            [ drawWhiteKey 0 0 0 3
            , drawBlackKey 4 0
            , drawWhiteKey 8 0 1 1
            , drawBlackKey 13 0
            , drawWhiteKey 17 0 3 0
            , drawWhiteKey 21 0 0 3
            , drawBlackKey 25 0
            , drawWhiteKey 29 0 1 2
            , drawBlackKey 33 0
            , drawWhiteKey 37 0 2 1
            , drawBlackKey 41 0
            , drawWhiteKey 45 0 3 0
            ]
        ]
    )

drawWhiteKey : Float -> Float -> Int -> Int -> List (Svg msg)
drawWhiteKey x y lThin rThin =
  [ path
      [ fill "white"
      , attribute "tabindex" "0"
      , style [ ( "cursor", "pointer" ) ]
      , dHelp
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
      ]
      []
  ]

drawBlackKey : Float -> Float -> List (Svg msg)
drawBlackKey x y =
  [ path
      [ fill "black"
      , attribute "tabindex" "0"
      , style [ ( "cursor", "pointer" ) ]
      , dHelp
          [ [ "M", toString (x + 0.25)
            , ",", toString (y + 0.25)
            , " v", toString (blackLength - 0.5)
            , " h3.5 v", toString -(blackLength - 0.5)
            ]
          ]
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
