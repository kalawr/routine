module External.Create exposing (create)

import Http exposing (..)
import Task exposing (..)
import Decode
import Encode
import Types exposing (..)

url : String
url =
  "/api/routines"

put : String -> Request Routine
put name =
  request
  { method = "PUT"
  , headers = []
  , url = url
  , body = jsonBody (Encode.routine name)
  , expect = expectJson Decode.routine
  , timeout = Nothing
  , withCredentials = False
  }

create : String -> Cmd Message
create name =
  send
    CreateResult
    (put name)