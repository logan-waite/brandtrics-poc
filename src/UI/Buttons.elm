module UI.Buttons exposing (default, iconButton, primary)

import Element exposing (Attribute, Element, padding)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input exposing (button)
import UI.Colors as Colors
import UI.Typography as Typography


default : List (Attribute msg) -> { onPress : Maybe msg, label : String } -> Element msg
default attributes { onPress, label } =
    Input.button
        (List.append
            [ padding 10, Border.rounded 4 ]
            attributes
        )
    <|
        { onPress = onPress
        , label = Typography.default [] label
        }


primary : List (Attribute msg) -> { onPress : Maybe msg, label : String } -> Element msg
primary attributes buttonInfo =
    default
        (List.append
            [ Background.color Colors.primary ]
            attributes
        )
        buttonInfo


iconButton : List (Attribute msg) -> { onPress : Maybe msg, icon : Element msg } -> Element msg
iconButton attributes { onPress, icon } =
    Input.button
        (List.append
            [ Border.rounded 4
            , Border.width 1
            , padding 5
            ]
            attributes
        )
        { onPress = onPress
        , label = icon
        }
