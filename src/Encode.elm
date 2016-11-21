module Encode exposing (..)

import Json.Encode exposing (..)
import Types exposing (..)

routine : String -> Value
routine name =
  object
    [ ("name", string name)
    ]

tickAction : Value
tickAction =
  object
  [ ("action", string "tick")
  ]

untickAction : Value
untickAction =
  object
  [ ("action", string "untick")
  ]

editAction : String -> Value
editAction name =
    object
    [ ("action", string "rename")
    , ("name", string name)
    ]