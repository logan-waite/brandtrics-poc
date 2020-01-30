module Main exposing (..)

-- import Element.Input as Input
-- import Element.Lazy exposing (lazy)

import Browser
import Browser.Navigation as Nav
import Element exposing (Element, alignLeft, alignRight, column, el, fill, height, link, padding, px, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Region as Region
import Features.EditBrand
import Features.Login
import Html exposing (Html)
import Html.Attributes
import UI.Colors as Colors
import UI.Helpers exposing (borderWidth, textEl)
import Url exposing (Url)
import Url.Builder as Builder exposing (relative)
import Url.Parser as Parser exposing ((</>), Parser, s, string)



---- MODEL ----


type alias Model =
    { page : Page
    , key : Nav.Key
    , menuOpen : Bool
    , user : Maybe User
    }


type alias User =
    { name : String }


type Page
    = Dashboard
    | LoginPage
    | RegisterPage
    | EditBrandPage Features.EditBrand.Model


type Route
    = Top
    | Login
    | Register
    | EditBrand


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        user =
            Just { name = "joe" }
    in
    ( initialModel url key user, checkLogin key user url )


initialModel : Url -> Nav.Key -> Maybe User -> Model
initialModel url key user =
    { page = urlToPage url
    , key = key
    , menuOpen = False
    , user = user
    }


urlToPage : Url -> Page
urlToPage url =
    case Parser.parse parser url of
        Just Top ->
            Dashboard

        Just EditBrand ->
            EditBrandPage {}

        Just Login ->
            LoginPage

        Just Register ->
            RegisterPage

        Nothing ->
            Dashboard


checkLogin : Nav.Key -> Maybe User -> Url -> Cmd Msg
checkLogin key user url =
    let
        route : Maybe Route
        route =
            Parser.parse parser url
    in
    if user == Nothing && not (List.member route externalRoutes) then
        Nav.pushUrl key (Builder.relative [ "login" ] [])

    else
        Cmd.none


externalRoutes : List (Maybe Route)
externalRoutes =
    [ Just Login, Just Register ]


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Top Parser.top
        , Parser.map Login (s "login")
        , Parser.map Register (s "register")
        , Parser.map EditBrand (s "edit")
        ]



---- UPDATE ----


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | ShowMenu
    | GotEditBrandMsg Features.EditBrand.Msg


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
            ( { model | page = urlToPage url, menuOpen = False }, checkLogin model.key model.user url )

        ShowMenu ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )

        GotEditBrandMsg editBrandMsg ->
            case model.page of
                EditBrandPage editBrandModel ->
                    toEditBrand model (Features.EditBrand.update editBrandMsg editBrandModel)

                _ ->
                    ( model, Cmd.none )


toEditBrand : Model -> ( Features.EditBrand.Model, Cmd Features.EditBrand.Msg ) -> ( Model, Cmd Msg )
toEditBrand model ( editBrand, cmd ) =
    ( { model | page = EditBrandPage editBrand }
    , Cmd.map GotEditBrandMsg cmd
    )



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
            [ if model.user /= Nothing then
                header

              else
                Element.none
            , Element.el
                [ height fill
                , width fill
                , Element.onRight (menu model.menuOpen)
                ]
                (featureScreen
                    model
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


featureScreen : Model -> Element Msg
featureScreen model =
    case model.page of
        EditBrandPage editBrandModel ->
            Features.EditBrand.view editBrandModel
                |> Element.map GotEditBrandMsg

        LoginPage ->
            textEl [] "Login"

        RegisterPage ->
            textEl [] "Register"

        Dashboard ->
            dashboard


featureButton : String -> String -> Element Msg
featureButton label url =
    link
        [ height (px 150)
        , width (px 150)
        , Border.width 1
        , Background.color Colors.background
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
