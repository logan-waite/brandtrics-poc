module Features.ExportStyleGuide exposing (Model, Msg, update, view)

import Element exposing (Element)
import UI.Typography as Typography


type alias Model =
    {}


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Element Msg
view model =
    Typography.default [] "Export Stylesheet Screen"
