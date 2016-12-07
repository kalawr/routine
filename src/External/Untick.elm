module External.Untick exposing (untick)

import Http exposing (..)
import Task exposing (..)
import Decode
import Encode
import Date exposing (Date)
import Types exposing (..)

url : Id ->  String
url id =
  id
  |> toString
  |> (++) "api/routines/"

request : Id -> Date -> Request (Id, Date)
request id date =
  post
    (url id)
    (jsonBody (Encode.untickAction date))
    Decode.tickResponse

untick : Id -> Date -> Cmd Message
untick id date = 
  send
    UntickResult
    (request id date)