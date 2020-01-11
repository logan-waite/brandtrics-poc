module UIHelpers exposing (borderWidth, textEl)

import Element exposing (Attribute, Element, el, text)


textEl : List (Attribute msg) -> String -> Element msg
textEl styles string =
    el styles (text string)


borderWidth : { bottom : Int, left : Int, right : Int, top : Int }
borderWidth =
    { bottom = 0, left = 0, right = 0, top = 0 }
