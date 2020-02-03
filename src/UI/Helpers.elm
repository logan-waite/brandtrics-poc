module UI.Helpers exposing (borderWidth, corners, textEl)

import Element exposing (Attribute, Element, el, text)


textEl : List (Attribute msg) -> String -> Element msg
textEl styles string =
    el styles (text string)


borderWidth : { bottom : Int, left : Int, right : Int, top : Int }
borderWidth =
    { bottom = 0, left = 0, right = 0, top = 0 }


corners : { topLeft : Int, topRight : Int, bottomLeft : Int, bottomRight : Int }
corners =
    { topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = 0 }
