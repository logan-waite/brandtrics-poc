module Main exposing (..)

-- import Element.Input as Input
-- import Element.Lazy exposing (lazy)

import Api
import Browser
import Browser.Navigation as Nav
import Element exposing (Element, alignLeft, alignRight, column, el, fill, height, link, padding, px, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Region as Region
import Features.EditBrand
import Html exposing (Html)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Pipeline exposing (required)
import Ports
import Session exposing (User)
import UI.Buttons as Buttons
import UI.Colors as Colors
import UI.Helpers exposing (borderWidth, textEl)
import UI.Typography as Typography
import Url exposing (Url)
import Url.Builder as Builder exposing (relative)
import Url.Parser as Parser exposing (Parser, s)



---- MODEL ----


type alias Model =
    { page : Page
    , key : Nav.Key
    , menuOpen : Bool
    , user : Maybe User
    }


type Page
    = Dashboard
    | EditBrandPage Features.EditBrand.Model


type Route
    = Top
    | EditBrand


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
urlToPage url =
    case Parser.parse parser url of
        Just Top ->
            Dashboard

        Just EditBrand ->
            EditBrandPage {}

        Nothing ->
            Dashboard


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
        ]



---- UPDATE ----


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | ShowMenu
    | GotEditBrandMsg Features.EditBrand.Msg
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

        GotEditBrandMsg editBrandMsg ->
            case model.page of
                EditBrandPage editBrandModel ->
                    toEditBrand model (Features.EditBrand.update editBrandMsg editBrandModel)

                _ ->
                    ( model, Cmd.none )

        OpenAuthModal ->
            ( model, Ports.openAuthModal () )

        UserLogin user ->
            ( { model | user = user }, Cmd.none )

        UserLogout ->
            ( { model | user = Nothing }, Cmd.none )

        OnError error ->
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
        [ textEl
            [ Font.bold
            , Font.size 50
            , padding 25
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
                , padding 25
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
            , Buttons.default [ Element.centerX ] { onPress = Just OpenAuthModal, label = "Logout" }
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



-- _ ->
--     Cmd.none


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
