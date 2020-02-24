module Features.EditBrand exposing (Model, Msg, init, update, view)

import Element exposing (Element)
import UI.Typography as Typography


init : ( Model, Cmd msg )
init =
    ( {}, Cmd.none )


type alias Model =
    {}


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Element Msg
view model =
    Typography.default [] "Edit the Brand Screen"
