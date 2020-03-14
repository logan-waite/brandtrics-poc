module Api exposing (deleteColor, getColors, updateColor)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Api.Request exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, field)
import Json.Encode as Encode exposing (encode)
import RemoteData exposing (RemoteData, WebData)


dataToCmd : (WebData a -> msg) -> Result Http.Error a -> msg
dataToCmd cmd =
    RemoteData.fromResult >> cmd


getColors : (WebData a -> msg) -> Decoder a -> Cmd msg
getColors cmd decoder =
    get
        { url = Endpoint.firestore
        , expect = Http.expectJson (dataToCmd cmd) (field "colors" decoder)
        }


deleteColor : (WebData a -> msg) -> Decoder a -> String -> Cmd msg
deleteColor cmd decoder id =
    delete
        { url = Endpoint.firestore
        , expect = Http.expectJson (dataToCmd cmd) (field "colors" decoder)
        , body = Http.stringBody "text/plain" id
        }


updateColor : (WebData a -> msg) -> Decoder a -> Encode.Value -> Cmd msg
updateColor cmd decoder color =
    put
        { url = Endpoint.firestore
        , expect = Http.expectJson (dataToCmd cmd) (field "colors" decoder)
        , body = Http.jsonBody color
        }
