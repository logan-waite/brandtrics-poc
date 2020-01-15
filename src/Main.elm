module Main exposing (..)

-- import Element.Input as Input
-- import Element.Lazy exposing (lazy)
-- import Features.EditBrand
-- import Features.ExportStyleGuide

import Browser
import Browser.Navigation as Nav
import Element exposing (Attribute, Element, alignLeft, alignRight, column, el, fill, height, link, padding, row, text, width)
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import UIHelpers exposing (borderWidth, textEl)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)



---- MODEL ----


type alias Model =
    { feature : Feature
    , key : Nav.Key
    }


type Feature
    = Dashboard
    | ExportStyleGuide
    | EditBrand


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { feature = urlToFeature url, key = key }, Cmd.none )


urlToFeature : Url -> Feature
urlToFeature url =
    Parser.parse parser url
        |> Maybe.withDefault Dashboard


parser : Parser (Feature -> a) a
parser =
    Parser.oneOf
        [ Parser.map Dashboard Parser.top
        , Parser.map EditBrand (s "edit")
        , Parser.map ExportStyleGuide (s "export")
        ]



---- UPDATE ----


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            ( { model | feature = urlToFeature url }, Cmd.none )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "Brandtrics"
    , body =
        [ layout model
        ]
    }


layout : Model -> Html Msg
layout model =
    Element.layout
        [ height fill, width fill ]
    <|
        column
            [ width fill ]
            [ header
            , featureScreen model.feature
            ]


header : Element Msg
header =
    row
        [ width fill
        , padding 15
        , Border.widthEach { borderWidth | bottom = 2 }
        ]
        [ textEl [ alignLeft, Font.bold ] "Brandtrics"
        , textEl [ alignRight ] "menu"
        ]


featureScreen : Feature -> Element Msg
featureScreen feature =
    case feature of
        ExportStyleGuide ->
            textEl [] "Export Style Guide"

        EditBrand ->
            textEl [] "Edit Brand"

        Dashboard ->
            dashboard


featureButton : String -> String -> Element Msg
featureButton label url =
    link [ padding 50 ] { url = url, label = textEl [] label }


dashboard : Element Msg
dashboard =
    Element.wrappedRow
        []
        [ featureButton "Export Style Guide" "/export"
        , featureButton "Edit Brand" "/edit"
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
