module Api exposing (authorizeUser)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http
import Json.Decode exposing (..)
import Json.Encode exposing (..)
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


authorizeUser : (WebData String -> msg) -> Cmd msg
authorizeUser cmd =
    get
        { url = Endpoint.authorizeUser
        , expect = Http.expectJson (RemoteData.fromResult >> cmd) (field "test" Json.Decode.string) |> Debug.log "on return"
        }
