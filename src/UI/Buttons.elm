module UI.Buttons exposing (default, primary)

import Element exposing (Attribute, Element, padding, rgb255)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input exposing (button)
import UI.Colors as Colors
import UI.Helpers exposing (textEl)


default : List (Attribute msg) -> { onPress : Maybe msg, label : String } -> Element msg
default attributes { onPress, label } =
    Input.button
        (List.append
            [ padding 10, Border.rounded 4 ]
            attributes
        )
    <|
        { onPress = onPress
        , label = textEl [] label
        }


primary : List (Attribute msg) -> { onPress : Maybe msg, label : String } -> Element msg
primary attributes buttonInfo =
    default
        (List.append
            [ Background.color (rgb255 0 255 0) ]
            attributes
        )
        buttonInfo
