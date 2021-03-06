module Decode exposing (..)

import Date exposing (Date)
import Json.Decode exposing (..)
import Types exposing (..)


routine : Decoder Routine
routine =
  map5
    Routine
    (field "name" string)
    (field "created" date)
    (field "progress" (list tick))
    (field "id" int)
    (succeed Nothing)

routines : Decoder (List Routine)
routines =
  list routine

id : Decoder Id
id =
    field "id" int

tick : Decoder Date
tick =
  (field "date" date)

tickResponse : Decoder (Id, Date)
tickResponse =
  map2
    (,)
    (field "routine" int)
    (field "date" date)

editResponse : Decoder (Id, String)
editResponse =
  map2
    (,)
    (field "id" int)
    (field "name" string)

date : Decoder Date
date =
  map Date.fromString string
  |> andThen 
    (\result ->
      case result of
        Ok date ->
          succeed date
        Err text ->
          fail text
    )