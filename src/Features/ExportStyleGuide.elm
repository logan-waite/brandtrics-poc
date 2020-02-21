module Features.ExportStyleGuide exposing (Model, Msg, update, view)

import Element exposing (Element)
import UI.Helpers exposing (textEl)


type alias Model =
    {}


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Element Msg
view model =
    textEl [] "Export Stylesheet Screen"
