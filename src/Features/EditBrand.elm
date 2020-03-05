module Features.EditBrand exposing (EditRoute(..), Model, Msg, init, update, view)

import Element exposing (Element, column, fill, height, link, padding, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Hex
import UI.Buttons as Buttons
import UI.Colors
import UI.Helpers exposing (borderWidth)
import UI.Typography as Typography


init : EditRoute -> ( Model, Cmd msg )
init area =
    ( { area = area }, Cmd.none )


type EditRoute
    = Logos
    | Colors
    | Fonts


type alias Model =
    { area : EditRoute }


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Element Msg
view model =
    row
        [ height fill, width fill ]
        [ sideNav
        , Element.el
            [ height fill
            , width fill
            ]
          <|
            case model.area of
                Logos ->
                    logosArea

                Colors ->
                    colorsArea

                Fonts ->
                    fontsArea
        ]


sideNav : Element Msg
sideNav =
    column
        [ height fill
        , padding 15
        , Border.widthEach { borderWidth | right = 2 }
        , Border.color (Element.rgb255 0 0 0)
        , spacing 10
        ]
        [ editAreaLink "/logos" "Logos"
        , editAreaLink "/colors" "Colors"
        , editAreaLink "/fonts" "Fonts"
        ]


editAreaLink : String -> String -> Element Msg
editAreaLink url label =
    link
        [ Font.center
        , width fill
        , padding 10
        ]
        { url = "/edit" ++ url, label = text label }



-- Color Area


colorsArea : Element Msg
colorsArea =
    areaContent
        "Colors"
        [ subSection
            "Main"
          <|
            row
                [ spacing 10 ]
                [ colorItem "dapper"
                , colorItem "bada55"
                , colorItem "f71da4"
                ]
        ]


colorItem : String -> Element Msg
colorItem color =
    let
        rgbValues : List Int
        rgbValues =
            splitColors 2 color []
                |> List.map (Hex.toDecimal >> extract (always -1))

        backgroundColor : Element.Attribute msg
        backgroundColor =
            if List.member -1 rgbValues then
                Background.gradient
                    { angle = 2.36
                    , steps =
                        [ UI.Colors.white
                        , UI.Colors.white
                        , UI.Colors.white
                        , UI.Colors.white
                        , Element.rgb255 255 0 0
                        , UI.Colors.white
                        , UI.Colors.white
                        , UI.Colors.white
                        , UI.Colors.white
                        ]
                    }

            else
                Background.color (toRgb rgbValues)
    in
    column
        [ spacing 10
        , padding 10
        , Border.shadow { offset = ( 0, 0 ), size = 1, blur = 3, color = UI.Colors.grey }
        ]
        [ colorDisplay backgroundColor
        , Typography.default [ Element.centerX ] ("#" ++ String.toUpper color)
        ]


colorDisplay : Element.Attribute Msg -> Element Msg
colorDisplay background =
    Element.el
        [ width (px 50)
        , height (px 50)
        , background
        , Border.width 1
        , Border.color UI.Colors.black
        , Element.centerX
        ]
        Element.none



-- Logo Area


logosArea : Element Msg
logosArea =
    areaContent "Logos" [ Element.none ]



-- Font Area


fontsArea : Element Msg
fontsArea =
    areaContent "Fonts" [ Element.none ]



-- Generic page sections


areaContent : String -> List (Element Msg) -> Element Msg
areaContent header content =
    column
        [ width fill
        , height fill
        ]
    <|
        List.append
            [ Typography.h1
                [ paddingXY 15 15 ]
                header
            ]
            (content
                |> List.map columnItem
            )


subSection : String -> Element Msg -> Element Msg
subSection subHeader content =
    column
        [ spacing 15 ]
        [ Typography.h2 [ padding 0 ] subHeader
        , content
        ]


columnItem : Element Msg -> Element Msg
columnItem content =
    Element.el
        [ Border.widthEach { borderWidth | top = 1 }
        , Border.color (Element.rgb255 50 50 50)
        , width fill
        , paddingXY 15 15
        ]
        content



-- Color Conversion Tools
{-
   Step 1: Split value into 3 colors (1/2 digits each)
   Step 2: Figure out each value from 0 to 255
   Step 3: Plug the values into an rgb255 function
-}


type alias HexColor =
    String


splitColors : Int -> HexColor -> List String -> List String
splitColors number string newList =
    if String.length string == 0 then
        newList

    else
        splitColors
            number
            (String.dropRight number string)
            (String.right number string :: newList)


toRgb : List Int -> Element.Color
toRgb intValues =
    case intValues of
        r :: g :: b :: _ ->
            Element.rgb255 r g b

        _ ->
            UI.Colors.white


extract : (e -> a) -> Result e a -> a
extract f x =
    case x of
        Ok a ->
            a

        Err e ->
            f e
