module Features.EditBrand exposing (Model, Msg, init, update, view)

import Element exposing (Element)
import UI.Helpers exposing (textEl)


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
    textEl [] "Edit the Brand Screen"
