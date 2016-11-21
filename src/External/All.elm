module External.All exposing (all)

import Http exposing (..)
import Task exposing (..)
import Decode
import Encode
import Types exposing (..)

url : String
url =
  "/api/routines"

request : Request (List Routine)
request = 
  get
    url
    Decode.routines

all : Cmd Message
all =
  send
    AllResult
    request
