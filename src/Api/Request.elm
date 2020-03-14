module Api.Request exposing (delete, get, put)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http


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


delete :
    { url : Endpoint
    , expect : Http.Expect msg
    , body : Http.Body
    }
    -> Cmd msg
delete { url, expect, body } =
    Endpoint.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = body
        , expect = expect
        , timeout = Nothing
        , tracker = Nothing
        }


put :
    { url : Endpoint
    , expect : Http.Expect msg
    , body : Http.Body
    }
    -> Cmd msg
put { url, expect, body } =
    Endpoint.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , expect = expect
        , timeout = Nothing
        , tracker = Nothing
        }
