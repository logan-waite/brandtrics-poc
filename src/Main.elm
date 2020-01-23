module Main exposing (..)

-- import Element.Input as Input
-- import Element.Lazy exposing (lazy)
-- import Features.EditBrand
-- import Features.ExportStyleGuide

import Browser
import Browser.Navigation as Nav
import Element exposing (Attribute, Element, alignLeft, alignRight, column, el, fill, height, link, padding, px, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Region as Region
import Html exposing (Html)
import Html.Attributes
import UI.Colors as Colors
import UI.Helpers exposing (borderWidth, textEl)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)



---- MODEL ----


type alias Model =
    { feature : Feature
    , key : Nav.Key
    , menuOpen : Bool
    }


type Feature
    = Dashboard
    | ExportStyleGuide
    | EditBrand


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel url key, Cmd.none )


initialModel : Url -> Nav.Key -> Model
initialModel url key =
    { feature = urlToFeature url
    , key = key
    , menuOpen = False
    }


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
    | ShowMenu


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
            ( { model | feature = urlToFeature url, menuOpen = False }, Cmd.none )

        ShowMenu ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )



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
        [ height fill, width fill, Background.color (rgb255 255 250 240) ]
    <|
        column
            [ width fill, height fill ]
            [ header
            , Element.el
                [ height fill
                , width fill
                , Element.onRight (menu model.menuOpen)
                ]
                (featureScreen
                    model.feature
                )
            ]


header : Element Msg
header =
    row
        [ width fill
        , height (px 50)
        , padding 15
        , Border.widthEach { borderWidth | bottom = 2 }
        , Background.color Colors.white
        ]
        [ link [ alignLeft ] { url = "/", label = textEl [ Font.bold ] "Brandtrics" }
        , textEl
            [ alignRight
            , Events.onClick ShowMenu
            ]
            "menu"
        ]


menu : Bool -> Element Msg
menu menuOpen =
    if menuOpen then
        column
            [ Region.navigation
            , Background.color Colors.white
            , padding 15
            , width (px 250)
            , Element.moveLeft 250
            , Border.widthEach { borderWidth | left = 2 }
            , height fill
            , alignRight
            ]
            [ navLink "/" "Dashboard"
            , navLink "/edit" "Edit Brand"
            , navLink "/export" "Export Style Guide"
            ]

    else
        Element.none


navLink : String -> String -> Element Msg
navLink url label =
    link
        [ Font.center
        , width fill
        , padding 10
        ]
        { url = url, label = text label }


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
    link
        [ height (px 150)
        , width (px 150)
        , Border.width 1
        , Background.color (rgb255 255 255 255)
        , Element.htmlAttribute (Html.Attributes.style "marginLeft" "auto")
        , Element.htmlAttribute (Html.Attributes.style "marginRight" "auto")
        ]
        { url = url
        , label =
            Element.paragraph
                [ Font.center ]
                [ textEl [] label ]
        }


dashboard : Element Msg
dashboard =
    Element.wrappedRow
        [ Element.spacing 50
        , Element.centerX
        , Element.centerY
        , width (fill |> Element.maximum 500)
        ]
        [ featureButton "Edit Brand" "/edit"
        , featureButton "Export Style Guide" "/export"
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
