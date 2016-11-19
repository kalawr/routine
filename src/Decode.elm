module Decode exposing (routine)

import Json.Decode exposing (..)
import Types exposing (..)

routine : Decoder Routine
routine =
  map2
    Routine
    (field "name" string)
    (field "id" int)