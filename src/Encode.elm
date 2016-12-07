module Encode exposing (..)

import Json.Encode exposing (..)
import Date exposing (Date)
import Date.Extra exposing (..)
import Types exposing (..)

routine : String -> Value
routine name =
  object
    [ ("name", string name)
    ]

tickAction : Date -> Value
tickAction date =
  object
  [ ("action", string "tick")
  , ( "date"
    , date
      |> toFormattedString "E MMM dd y"
      |> string
    )
  ]

untickAction : Date -> Value
untickAction date =
  object
  [ ("action", string "untick")
  , ( "date"
    , date
      |> toFormattedString "E MMM dd y"
      |> string
    )
  ]

editAction : String -> Value
editAction name =
    object
    [ ("action", string "rename")
    , ("name", string name)
    ]