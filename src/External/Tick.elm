module External.Tick exposing (tick)

import Http exposing (..)
import Task exposing (..)
import Decode
import Encode
import Types exposing (..)
import Date exposing (Date)

url : Id ->  String
url id =
  id
  |> toString
  |> (++) "api/routines/"

request : Id -> Date -> Request (Id, Date)
request id date =
  post
    (url id)
    (jsonBody (Encode.tickAction date))
    Decode.tickResponse

tick : Id -> Date -> Cmd Message
tick id date = 
  send
    TickResult
    (request id date)