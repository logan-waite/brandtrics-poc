module UI.Typography exposing (default, h1, h2)

import Element exposing (Attribute, Element, el, paddingXY, text)
import Element.Font as Font
import Element.Region as Region exposing (heading)


h1 : List (Attribute msg) -> String -> Element msg
h1 attributes string =
    el
        (List.append
            [ heading 1
            , paddingXY 0 15
            , Font.size 42
            ]
            attributes
        )
        (text string)


h2 : List (Attribute msg) -> String -> Element msg
h2 attributes string =
    el
        (List.append
            [ heading 2
            , paddingXY 0 10
            , Font.size 30
            ]
            attributes
        )
        (text string)


default : List (Attribute msg) -> String -> Element msg
default styles string =
    el styles (text string)
