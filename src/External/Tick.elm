module External.Tick exposing (tick)

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

request : Id -> Request TickResponse
request id =
  post
    (url id)
    (jsonBody Encode.tickAction)
    Decode.tickResponse

tick : Id -> Cmd Message
tick id = 
  send
    TickResult
    (request id)