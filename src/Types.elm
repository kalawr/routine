module Types exposing (..)

import Http exposing (Error(..))

type alias Model =
  { new : String
  , routines : List Routine
  }

type alias Routine =
  { name : String
  --, progress : List Int
  --, streak : Int
  , id : Id
  }

--type alias Day =
--  { date : Date
--  , good : Bool
--  }

type alias Id =
  Int

type Message
  = NewName String
  | Create
  | CreateResult (Result Error Routine)