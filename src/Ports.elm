port module Ports exposing (..)

import Json.Encode as Encode


port openAuthModal : () -> Cmd msg


port userAuth : (Encode.Value -> msg) -> Sub msg
