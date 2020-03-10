module Main exposing (..)

import Api
import Browser
import Browser.Navigation as Nav
import Element exposing (Element, alignLeft, alignRight, column, el, fill, height, link, padding, px, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Region as Region
import Features.Dashboard
import Features.EditBrand exposing (EditRoute(..))
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Pipeline exposing (required)
import Ports
import Session exposing (User)
import UI.Buttons as Buttons
import UI.Colors as Colors
import UI.Helpers exposing (borderWidth)
import UI.Spacing exposing (medium, small, xsmall)
import UI.Typography as Typography
import Url exposing (Url)
import Url.Builder as Builder exposing (relative)
import Url.Parser as Parser exposing ((</>), Parser, s)



---- MODEL ----


type alias Model =
    { page : Page
    , key : Nav.Key
    , menuOpen : Bool
    , user : Maybe User
    , 
    }


type Page
    = DashboardPage Features.Dashboard.Model
    | EditBrandPage Features.EditBrand.Model


type Route
    = Top
    | EditBrand
    | EditLogos
    | EditColors
    | EditFonts


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        user =
            Nothing
    in
    ( initialModel url key user, Cmd.none )


initialModel : Url -> Nav.Key -> Maybe User -> Model
initialModel url key user =
    { page = urlToPage url
    , key = key
    , menuOpen = False
    , user = user
    }


urlToPage : Url -> Page
urlToPage url model =
    case Parser.parse parser url of
        Just Top ->
            DashboardPage {}

        Just EditBrand ->
            EditBrandPage { area = Logos }

        Just EditLogos ->
            EditBrandPage { area = Logos }

        Just EditColors ->
            EditBrandPage { area = Colors }

        Just EditFonts ->
            EditBrandPage { area = Fonts }

        Nothing ->
            DashboardPage {}


checkLogin : Nav.Key -> Maybe User -> Url -> Cmd Msg
checkLogin key user url =
    let
        route : Maybe Route
        route =
            Parser.parse parser url
    in
    if user == Nothing then
        Nav.pushUrl key (Builder.relative [ "login" ] [])

    else
        Cmd.none


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Top Parser.top
        , Parser.map EditBrand (s "edit")
        , Parser.map EditLogos (s "edit" </> s "logos")
        , Parser.map EditColors (s "edit" </> s "colors")
        , Parser.map EditFonts (s "edit" </> s "fonts")
        ]



---- UPDATE ----


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | ShowMenu
    | GotEditBrandMsg Features.EditBrand.Msg
    | GotDashboardMsg Features.Dashboard.Msg
    | OnError String
    | OpenAuthModal
    | UserLogin (Maybe User)
    | UserLogout



-- | CheckedAuth (WebData String)


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

        OpenAuthModal ->
            ( model, Ports.openAuthModal () )

        UserLogin user ->
            ( { model | user = user }, Cmd.none )

        UserLogout ->
            ( { model | user = Nothing }, Cmd.none )

        OnError error ->
            ( model, Cmd.none )

        GotEditBrandMsg editBrandMsg ->
            case model.page of
                EditBrandPage editBrandModel ->
                    toEditBrand model (Features.EditBrand.update editBrandMsg editBrandModel)

                _ ->
                    ( model, Cmd.none )

        GotDashboardMsg dashboardMsg ->
            case model.page of
                DashboardPage dashboardModel ->
                    toDashboard model (Features.Dashboard.update dashboardMsg dashboardModel)

                _ ->
                    ( model, Cmd.none )


toEditBrand : Model -> ( Features.EditBrand.Model, Cmd Features.EditBrand.Msg ) -> ( Model, Cmd Msg )
toEditBrand model ( editBrand, cmd ) =
    ( { model | page = EditBrandPage editBrand }
    , Cmd.map GotEditBrandMsg cmd
    )


toDashboard : Model -> ( Features.Dashboard.Model, Cmd Features.Dashboard.Msg ) -> ( Model, Cmd Msg )
toDashboard model ( dashboard, cmd ) =
    ( { model | page = DashboardPage dashboard }
    , Cmd.map GotDashboardMsg cmd
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
            (titleOrFeatureScreen model)


titleOrFeatureScreen : Model -> List (Element Msg)
titleOrFeatureScreen model =
    if model.user == Nothing then
        [ titleScreen ]

    else
        [ header
        , Element.el
            [ height fill
            , width fill
            , Element.onRight (menu model.menuOpen)
            ]
            (featureScreen
                model
            )
        ]


titleScreen : Element Msg
titleScreen =
    Element.column
        [ Element.centerX, height fill ]
        [ Typography.default
            [ Font.bold
            , Font.size 50
            , padding medium
            ]
            "Brandtrics"
        , Element.column
            [ width fill
            , Element.centerY
            , Element.moveUp 100
            ]
            [ Element.image
                [ width (fill |> Element.maximum 200)
                , Element.centerX
                , padding medium
                ]
                { src = "/logo.svg", description = "Elm Lang Logo" }
            , Typography.h1 [ Element.centerX ] "Your Company Name Here"
            ]
        , Buttons.default [ Element.centerX, Element.centerY ] { onPress = Just OpenAuthModal, label = "Login" }
        ]


header : Element Msg
header =
    row
        [ width fill
        , height (px 50)
        , padding small
        , Border.widthEach { borderWidth | bottom = 2 }
        , Background.color Colors.white
        ]
        [ link [ alignLeft ] { url = "/", label = Typography.default [ Font.bold ] "Brandtrics" }
        , Typography.default
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
            , padding small
            , width (px 250)
            , Element.moveLeft 250
            , Border.widthEach { borderWidth | left = 2 }
            , height fill
            , alignRight
            ]
            [ navLink "/" "Dashboard"
            , navLink "/edit" "Edit Brand"
            , navLink "/export" "Export Style Guide"
            , Buttons.default [ Element.centerX ] { onPress = Just OpenAuthModal, label = "Logout" }
            ]

    else
        Element.none


navLink : String -> String -> Element Msg
navLink url label =
    link
        [ Font.center
        , width fill
        , padding xsmall
        ]
        { url = url, label = text label }


featureScreen : Model -> Element Msg
featureScreen model =
    case model.page of
        EditBrandPage editBrandModel ->
            Features.EditBrand.view editBrandModel
                |> Element.map GotEditBrandMsg

        DashboardPage dashboardModel ->
            Features.Dashboard.view dashboardModel
                |> Element.map GotDashboardMsg


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.userAuth (Decode.decodeValue authDecoder >> authType)
        ]


authType : Result Decode.Error AuthAction -> Msg
authType result =
    case result of
        Ok value ->
            case value.action of
                "login" ->
                    UserLogin value.payload

                "logout" ->
                    UserLogout

                _ ->
                    Debug.log "action error" "Unknown auth action taken"
                        |> OnError

        Err error ->
            Debug.log "authType error" error
                |> Decode.errorToString
                |> OnError


type alias AuthAction =
    { action : String
    , payload : Maybe User
    }


authDecoder : Decoder AuthAction
authDecoder =
    Decode.map2 AuthAction
        (field "action" Decode.string)
        (Decode.maybe (field "payload" userDecoder))


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "email" Decode.string



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
