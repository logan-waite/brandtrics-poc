module Session exposing (..)

import Http


type alias User =
    { email : String }


type SessionStatus
    = UnAuthorized
    | Authorized


type alias Session =
    { status : SessionStatus }


session : Session
session =
    { status = UnAuthorized }
