module External.Edit exposing (edit)

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

request : Id -> String -> Request (Id, String)
request id name =
  post
    (url id)
    (jsonBody (Encode.editAction name))
    Decode.editResponse

edit : Id -> String -> Cmd Message
edit id name = 
  send
    EditResult
    (request id name)