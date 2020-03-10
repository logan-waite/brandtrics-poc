module Libraries.Icons exposing (icon)

import Element exposing (Color, Element, html)
import Svg exposing (Svg)
import Svg.Attributes exposing (fill, height, viewBox, width)


icon : String -> List (Svg msg) -> Color -> Int -> Element msg
icon viewbox children color size =
    let
        stringSize =
            String.fromInt size

        stringColor =
            toRgbaString color
    in
    html <|
        Svg.svg
            [ width stringSize
            , height stringSize
            , viewBox viewbox
            ]
            [ Svg.g
                [ fill stringColor ]
                children
            ]


toRgbaString : Color -> String
toRgbaString color =
    let
        { red, green, blue, alpha } =
            Element.toRgb color
    in
    "rgba("
        ++ String.fromInt (round (255 * red))
        ++ ","
        ++ String.fromInt (round (255 * green))
        ++ ","
        ++ String.fromInt (round (255 * blue))
        ++ ","
        ++ String.fromFloat alpha
        ++ ")"
