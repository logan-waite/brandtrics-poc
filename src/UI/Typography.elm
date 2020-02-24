module UI.Typography exposing (default, h1)

import Element exposing (..)


h1 : List (Attribute msg) -> String -> Element msg
h1 attributes string =
    el
        (List.append
            [ padding 10 ]
            attributes
        )
        (text string)


default : List (Attribute msg) -> String -> Element msg
default styles string =
    el styles (text string)
