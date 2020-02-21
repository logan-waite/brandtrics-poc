module Api.Endpoint exposing (Endpoint, authorizeUser, request)

import Http
import Json.Encode
import Url.Builder exposing (QueryParameter)



-- REQUEST DEFINITIONS
-- Mirror HTTP requests, but take Enpoints instead of Urls.


{-| Custom request
-}
request :
    { method : String
    , headers : List Http.Header
    , url : Endpoint
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
request config =
    let
        _ =
            Debug.log "request config" config.body
    in
    Http.request
        { method = config.method
        , headers = config.headers
        , url = unwrap config.url |> Debug.log "url"
        , body = config.body
        , expect = config.expect
        , timeout = config.timeout
        , tracker = config.tracker
        }



-- TYPES


{-| Get a URL to the Conduit API.
This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.
-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    -- NOTE: Url.Builder takes care of percent-encoding special URL characters.
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url#percentEncode
    Url.Builder.crossOrigin "https://conduit.productionready.io"
        ("api" :: paths)
        queryParams
        |> Endpoint


function : String -> Endpoint
function func =
    Url.Builder.absolute
        [ ".netlify", "functions", func ]
        []
        |> Endpoint



-- FUNCTIONS


authorizeUser : Endpoint
authorizeUser =
    function "user-auth"
