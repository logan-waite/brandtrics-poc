module Api exposing (getColors)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import RemoteData exposing (RemoteData, WebData)


get :
    { url : Endpoint
    , expect : Http.Expect msg
    }
    -> Cmd msg
get { url, expect } =
    Endpoint.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = expect
        , timeout = Nothing
        , tracker = Nothing
        }


type alias Test =
    { test : String }


type ResponseAction e a
    = RemoteData e a


getColors : Decoder a -> (WebData a -> msg) -> Cmd msg
getColors decoder cmd =
    get
        { url = Endpoint.firestore
        , expect = Http.expectJson (RemoteData.fromResult >> cmd) (field "colors" decoder) |> Debug.log "on return"
        }
