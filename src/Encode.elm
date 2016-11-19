module Encode exposing (..)

import Json.Encode exposing (..)
import Types exposing (..)

routine : Model -> Value
routine model =
  object
    [ ("name", string model.new)
    ]