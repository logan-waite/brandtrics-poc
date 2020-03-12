module Features.EditBrand exposing (Model, Msg, init, initialModel, update, view)

import Element exposing (Element, column, fill, height, link, padding, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Libraries.Hex as Hex
import List.Extra
import Router exposing (EditBrandRoute(..))
import UI.Buttons
import UI.Colors
import UI.Helpers exposing (borderWidth)
import UI.Icons as Icons
import UI.Spacing exposing (medium, small, xsmall)
import UI.Typography as Typography


init : ( Model, Cmd msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { colors = brandColors
    }


type alias Model =
    { colors : List BrandColor
    }


type alias HexColor =
    String


type alias BrandColor =
    { hex : HexColor
    , category : String
    , editing : Bool
    , id : Int
    }


brandColors : List BrandColor
brandColors =
    [ { hex = "DAPPER"
      , category = "main"
      , editing = False
      , id = 1
      }
    , { hex = "BADA55"
      , category = "main"
      , editing = False
      , id = 2
      }
    , { hex = "FA4769"
      , category = "secondary"
      , editing = False
      , id = 3
      }
    ]



-- UPDATE


type Msg
    = EditColor BrandColor
    | UpdateColorHex BrandColor HexColor


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditColor color ->
            let
                updatedColors =
                    setColorEditing True color model.colors
            in
            ( { model | colors = updatedColors }, Cmd.none )

        UpdateColorHex color value ->
            let
                updatedColors =
                    updateColorHexValue color value model.colors
            in
            ( { model | colors = updatedColors }, Cmd.none )


updateColorHexValue : BrandColor -> HexColor -> List BrandColor -> List BrandColor
updateColorHexValue color hexValue colors =
    let
        colorIndex =
            List.Extra.elemIndex color colors
    in
    updateColorAtIndex (\c -> { c | hex = hexValue }) colorIndex colors


setColorEditing : Bool -> BrandColor -> List BrandColor -> List BrandColor
setColorEditing value color colors =
    let
        colorIndex =
            List.Extra.elemIndex color colors
    in
    updateColorAtIndex (\c -> { c | editing = value }) colorIndex colors


updateColorAtIndex : (BrandColor -> BrandColor) -> Maybe Int -> List BrandColor -> List BrandColor
updateColorAtIndex colorUpdateFn index colors =
    case index of
        Just i ->
            List.Extra.updateAt i colorUpdateFn colors

        Nothing ->
            colors



-- VIEW


view : EditBrandRoute -> Model -> Element Msg
view route model =
    row
        [ height fill, width fill ]
        [ sideNav
        , Element.el
            [ height fill
            , width fill
            ]
          <|
            case route of
                Logos ->
                    logosArea

                Colors ->
                    colorsArea model.colors

                Fonts ->
                    fontsArea
        ]


sideNav : Element Msg
sideNav =
    column
        [ height fill
        , padding small
        , Border.widthEach { borderWidth | right = 2 }
        , Border.color (Element.rgb255 0 0 0)
        , spacing xsmall
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
        , padding xsmall
        ]
        { url = "/edit" ++ url, label = text label }



-- Color Area


colorsArea : List BrandColor -> Element Msg
colorsArea colors =
    areaContent
        "Colors"
        [ subSection
            "Main"
          <|
            row
                [ spacing medium ]
                (List.map colorItem colors)
        ]


colorItem : BrandColor -> Element Msg
colorItem color =
    let
        rgbValues : List Int
        rgbValues =
            splitColors 2 color.hex []
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
        [ spacing xsmall
        , padding xsmall
        , Border.shadow { offset = ( 0, 0 ), size = 1, blur = 3, color = UI.Colors.grey }
        ]
        [ colorDisplay backgroundColor
        , if not color.editing then
            Typography.default [ Element.centerX ] ("#" ++ String.toUpper color.hex)

          else
            Input.text [] { onChange = UpdateColorHex color, placeholder = Just (Input.placeholder [] (text "Hex Value")), text = color.hex, label = Input.labelHidden "Hex Value" }
        , row
            [ Element.spaceEvenly, width fill, Element.alignRight ]
            [ if color.editing then
                UI.Buttons.iconButton [ Border.color UI.Colors.red ] { onPress = Nothing, icon = Icons.trashCan 20 UI.Colors.red }

              else
                Element.none
            , showEditOrSaveButton color.editing (Just (EditColor color)) Nothing
            ]
        ]


showEditOrSaveButton : Bool -> Maybe Msg -> Maybe Msg -> Element Msg
showEditOrSaveButton editing editEvent saveEvent =
    if editing then
        UI.Buttons.iconButton [] { onPress = saveEvent, icon = Icons.check 20 UI.Colors.black }

    else
        UI.Buttons.iconButton [] { onPress = editEvent, icon = Icons.pencil 20 UI.Colors.black }


colorDisplay : Element.Attribute Msg -> Element Msg
colorDisplay background =
    Element.el
        [ width (px 100)
        , height (px 100)
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
                [ paddingXY small small ]
                header
            ]
            (content
                |> List.map columnItem
            )


subSection : String -> Element Msg -> Element Msg
subSection subHeader content =
    column
        [ spacing small ]
        [ Typography.h2 [ padding 0 ] subHeader
        , content
        ]


columnItem : Element Msg -> Element Msg
columnItem content =
    Element.el
        [ Border.widthEach { borderWidth | top = 1 }
        , Border.color (Element.rgb255 50 50 50)
        , width fill
        , paddingXY small small
        ]
        content



-- Color Conversion Tools
{-
   Step 1: Split value into 3 colors (1/2 digits each)
   Step 2: Figure out each value from 0 to 255
   Step 3: Plug the values into an rgb255 function
-}


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



-- Helpers


extract : (e -> a) -> Result e a -> a
extract f x =
    case x of
        Ok a ->
            a

        Err e ->
            f e
