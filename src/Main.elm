module Main exposing (..)

import Browser
import Dashboard
import Element exposing (Attribute, Element, alignLeft, alignRight, column, el, fill, height, padding, row, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import UIHelpers exposing (borderWidth, textEl)



---- MODEL ----


type alias Model =
    { feature : Maybe Feature
    }


initialModel =
    { feature = Nothing
    }


type Feature
    = ExportStyleGuide
    | EditBrand


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = ChangeFeature (Maybe Feature)
    | GotDashboardMsg Dashboard.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeFeature feature ->
            ( { model | feature = feature }, Cmd.none )

        GotDashboardMsg dashboardMsg ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout
        [ height fill, width fill ]
    <|
        column
            [ width fill ]
            [ row
                [ width fill
                , padding 15
                , Border.widthEach { borderWidth | bottom = 2 }
                ]
                [ textEl [ alignLeft, Font.bold ] "Brandtrics"
                , textEl [ alignRight ] "menu"
                ]
            , row
                []
                [ featureButton "Export Style Guide" ExportStyleGuide
                , featureButton "Edit Brand" EditBrand
                ]
            , featureScreen model.feature
            ]


featureScreen : Maybe Feature -> Element Msg
featureScreen feature =
    case feature of
        Just ExportStyleGuide ->
            textEl [] "Export Style Guide"

        Just EditBrand ->
            textEl [] "Edit Brand"

        Nothing ->
            Dashboard.view Dashboard.Model
                |> Element.map GotDashboardMsg


featureButton : String -> Feature -> Element Msg
featureButton label feature =
    Input.button [ padding 50 ] { onPress = Just (ChangeFeature (Just feature)), label = textEl [] label }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
