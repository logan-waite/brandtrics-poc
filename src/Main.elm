module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Element exposing (Element, alignLeft, alignRight, column, el, fill, height, link, padding, px, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Region as Region
import Features.Dashboard
import Features.EditBrand
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Pipeline exposing (required)
import Ports
import Router exposing (Route(..), urlToRoute)
import Session exposing (User)
import UI.Buttons as Buttons
import UI.Colors as Colors
import UI.Helpers exposing (borderWidth)
import UI.Spacing exposing (medium, small, xsmall)
import UI.Typography as Typography
import Url exposing (Url)
import Url.Builder as Builder exposing (relative)



---- MODEL ----


type alias Model =
    { route : Maybe Route
    , key : Nav.Key
    , menuOpen : Bool
    , user : Maybe User
    , editBrandModel : Features.EditBrand.Model
    , dashboardModel : Features.Dashboard.Model
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        user =
            Nothing
    in
    initialModel key user
        |> updateUrl url


initialModel : Nav.Key -> Maybe User -> Model
initialModel key user =
    { route = Just Top
    , key = key
    , menuOpen = False
    , user = user
    , editBrandModel = Features.EditBrand.initialModel
    , dashboardModel = Features.Dashboard.initialModel
    }


checkLogin : Nav.Key -> Maybe User -> Cmd Msg
checkLogin key user =
    if user == Nothing then
        Nav.pushUrl key (Builder.relative [ "login" ] [])

    else
        Cmd.none


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    let
        updatedModel =
            { model | route = urlToRoute url }
    in
    case updatedModel.route of
        Just (EditBrand _) ->
            Features.EditBrand.init model.editBrandModel
                |> toEditBrand model

        Just Top ->
            Features.Dashboard.init model.dashboardModel
                |> toDashboard model

        Nothing ->
            ( model, Cmd.none )



---- UPDATE ----


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | ShowMenu
    | EditBrandMsg Features.EditBrand.Msg
    | DashboardMsg Features.Dashboard.Msg
    | OnError String
    | OpenAuthModal
    | UserLogin (Maybe User)
    | UserLogout


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
            ( { model | route = urlToRoute url, menuOpen = False }, checkLogin model.key model.user )

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

        EditBrandMsg editBrandMsg ->
            Features.EditBrand.update editBrandMsg model.editBrandModel
                |> toEditBrand model

        DashboardMsg dashboardMsg ->
            Features.Dashboard.update dashboardMsg model.dashboardModel
                |> toDashboard model


toEditBrand : Model -> ( Features.EditBrand.Model, Cmd Features.EditBrand.Msg ) -> ( Model, Cmd Msg )
toEditBrand model ( editBrandModel, editBrandMsg ) =
    ( { model | editBrandModel = editBrandModel }
    , Cmd.map EditBrandMsg editBrandMsg
    )


toDashboard : Model -> ( Features.Dashboard.Model, Cmd Features.Dashboard.Msg ) -> ( Model, Cmd Msg )
toDashboard model ( dashboardModel, dashboardMsg ) =
    ( { model | dashboardModel = dashboardModel }
    , Cmd.map DashboardMsg dashboardMsg
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
    case model.route of
        Just (EditBrand subRoute) ->
            Features.EditBrand.view subRoute model.editBrandModel
                |> Element.map EditBrandMsg

        Just Top ->
            Features.Dashboard.view model.dashboardModel
                |> Element.map DashboardMsg

        Nothing ->
            Typography.h1 [] "404"


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
