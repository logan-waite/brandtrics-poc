module Login exposing (Model, Msg, init, update, view)

import Element exposing (Element, column, row)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import UI.Buttons as Buttons
import UI.Helpers exposing (textEl)


init : ( Model, Cmd msg )
init =
    ( { email = "", password = "" }, Cmd.none )


type alias Email =
    String


type alias Password =
    String


type alias Model =
    { email : Email
    , password : Password
    }


type Msg
    = Email Email
    | Password Password
    | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Email email ->
            ( { model | email = email }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( model, Cmd.none )


view : Model -> Element Msg
view model =
    column
        [ Element.centerX, Element.centerY, Element.spacing 15 ]
        [ textEl
            [ Element.centerX, Font.bold ]
            "Brandtrics"
        , Input.email
            []
            { onChange = Email
            , text = model.email
            , placeholder = Nothing
            , label = Input.labelAbove [] (textEl [] "Email")
            }
        , Input.currentPassword
            []
            { onChange = Password
            , text = model.password
            , placeholder = Nothing
            , label = Input.labelAbove [] (textEl [] "Password")
            , show = False
            }
        , Buttons.default
            [ Element.alignRight, Border.width 2 ]
            { onPress = Just Submit
            , label = "Submit"
            }
        , Element.link
            [ Element.centerX, Font.size 16 ]
            { url = "/register"
            , label = textEl [] "Register"
            }
        ]
