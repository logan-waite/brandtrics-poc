module UI.Typography exposing (..)

import Element exposing (..)


h1 : List (Attribute msg) -> String -> Element msg
h1 attributes string =
    el
        (List.append
            [ padding 10 ]
            attributes
        )
        (text string)
