module External.Create exposing (create)

import Http exposing (..)
import Task exposing (..)
import Decode
import Encode
import Types exposing (..)

url : String
url =
  "/api/routines"

request : Model -> Request Routine
request model =
  post
    url
    (jsonBody (Encode.routine model))
    Decode.routine

create : Model -> Cmd Message
create model =
  send
    CreateResult
    (request model)