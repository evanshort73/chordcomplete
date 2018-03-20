module Gradients exposing (keyboardGradients)

import Svg exposing (Svg, defs, linearGradient, stop)
import Svg.Attributes exposing (id, offset, x1, x2, y1, y2)
import Html.Attributes exposing (style)

keyboardGradients : Svg msg
keyboardGradients =
  defs []
    [ linearGradient
        [ id "blackKey"
        , y1 "0%"
        , y2 "100%"
        , x1 "50%"
        , x2 "50%"
        ]
        [ stop
            [ offset "0%"
            , style
                [ ( "stop-color", "white" )
                , ( "stop-opacity", "0.30" )
                ]
            ]
            []
        , stop
            [ offset "100%"
            , style
                [ ( "stop-color", "white" )
                , ( "stop-opacity", "1" )
                ]
            ]
            []
        ]
    ]
