module External.Untick exposing (untick)

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

request : Id -> Request Id
request id =
  post
    (url id)
    (jsonBody Encode.untickAction)
    Decode.id

untick : Id -> Cmd Message
untick id = 
  send
    UntickResult
    (request id)