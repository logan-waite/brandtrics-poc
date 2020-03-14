module Features.EditBrand exposing (Model, Msg, init, initialModel, update, view)

import Api
import Element exposing (Element, column, fill, height, link, padding, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Libraries.Hex as Hex
import List.Extra
import RemoteData exposing (RemoteData(..), WebData)
import Router exposing (EditBrandRoute(..))
import String exposing (cons)
import UI.Buttons
import UI.Colors
import UI.Helpers exposing (borderWidth)
import UI.Icons as Icons
import UI.Spacing exposing (medium, small, xsmall)
import UI.Typography as Typography


init : Model -> ( Model, Cmd Msg )
init model =
    if List.isEmpty model.colors then
        update GetColors model

    else
        ( model, Cmd.none )


initialModel : Model
initialModel =
    { colors = []
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
    , id : String
    }



-- UPDATE


type Msg
    = ColorRequest (WebData (List BrandColor))
    | GetColors
    | EditColor BrandColor
    | UpdateColorHex BrandColor HexColor
    | SaveColor BrandColor
    | RemoveColor BrandColor


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

        SaveColor color ->
            let
                encode : BrandColor -> Encode.Value
                encode c =
                    Encode.object
                        [ ( "hex", Encode.string c.hex )
                        , ( "category", Encode.string c.category )
                        , ( "id", Encode.string c.id )
                        ]
            in
            ( model, Api.updateColor ColorRequest colorListDecoder (encode color) )

        RemoveColor color ->
            ( model, Api.deleteColor ColorRequest colorListDecoder color.id )

        GetColors ->
            ( model, Api.getColors ColorRequest colorListDecoder )

        ColorRequest colors ->
            let
                newModel =
                    case colors of
                        NotAsked ->
                            model

                        Loading ->
                            model

                        Failure _ ->
                            model

                        Success colorList ->
                            { model | colors = colorList }
            in
            ( newModel, Cmd.none )



-- Color Updates


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



-- Color Decoders


colorListDecoder : Decoder (List BrandColor)
colorListDecoder =
    Decode.list colorDecoder


colorDecoder : Decoder BrandColor
colorDecoder =
    Decode.succeed BrandColor
        |> required "hex" string
        |> required "category" string
        |> hardcoded False
        |> required "id" string



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
                    colorsArea (groupColors model.colors)

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


colorsArea : List ( String, List BrandColor ) -> Element Msg
colorsArea colors =
    areaContent
        "Colors"
    <|
        List.map
            (\category ->
                subSection
                    (stringToTitleCase (Tuple.first category))
                <|
                    row
                        [ spacing medium ]
                        (List.map colorItem (Tuple.second category))
            )
            colors


colorItem : BrandColor -> Element Msg
colorItem color =
    let
        rgbValues : Maybe (List Int)
        rgbValues =
            correctColorLength color.hex
                |> Maybe.andThen convertHex

        backgroundColor : Element.Attribute msg
        backgroundColor =
            case rgbValues of
                Nothing ->
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

                Just values ->
                    Background.color (toRgb values)
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
                UI.Buttons.iconButton [ Border.color UI.Colors.red ] { onPress = Just (RemoveColor color), icon = Icons.trashCan 20 UI.Colors.red }

              else
                Element.none
            , showEditOrSaveButton color.editing (Just (EditColor color)) (Just (SaveColor color))
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


convertHex : List String -> Maybe (List Int)
convertHex hex =
    List.map (Hex.toDecimal >> Result.toMaybe) hex
        |> combine


correctColorLength : HexColor -> Maybe (List String)
correctColorLength hex =
    if String.length hex == 6 then
        Just (splitColors 2 [] hex)

    else if String.length hex == 3 then
        String.foldr (\letter acc -> cons letter acc |> cons letter) "" hex
            |> splitColors 2 []
            |> Just

    else
        Nothing


splitColors : Int -> List String -> HexColor -> List String
splitColors number segments string =
    if String.length string == 0 then
        segments

    else
        splitColors
            number
            (String.right number string :: segments)
            (String.dropRight number string)


toRgb : List Int -> Element.Color
toRgb intValues =
    case intValues of
        r :: g :: b :: _ ->
            Element.rgb255 r g b

        _ ->
            UI.Colors.white



-- Helpers


firstToUpper : String -> String
firstToUpper string =
    let
        firstLetter =
            String.left 1 string
                |> String.toUpper
    in
    String.dropLeft 1 string
        |> String.append firstLetter


stringToTitleCase : String -> String
stringToTitleCase string =
    String.words string
        |> List.map firstToUpper
        |> String.join " "


groupColors : List BrandColor -> List ( String, List BrandColor )
groupColors colors =
    let
        groupByCategory : BrandColor -> BrandColor -> Bool
        groupByCategory a b =
            a.category == b.category

        grouped =
            List.Extra.groupWhile groupByCategory colors
    in
    List.map (\t -> ( .category (Tuple.first t), Tuple.first t :: Tuple.second t )) grouped


combine : List (Maybe a) -> Maybe (List a)
combine =
    List.foldr (Maybe.map2 (::)) (Just [])


extract : (e -> a) -> Result e a -> a
extract f x =
    case x of
        Ok a ->
            a

        Err e ->
            f e
