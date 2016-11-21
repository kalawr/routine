module External.Delete exposing (delete)

import Http exposing (..)
import Task exposing (..)
import Decode
import Encode
import Types exposing (..)

url : Id ->  String
url id =
  id
  |> toString
  |> (++) "api/routines/"

delRequest : Id -> Request Id
delRequest id =
  request
    { method = "DELETE"
    , headers = []
    , url = url id
    , body = emptyBody
    , expect = expectJson Decode.id
    , timeout = Nothing
    , withCredentials = False
    }

delete : Id -> Cmd Message
delete id = 
  send
    DeleteResult
    (delRequest id)