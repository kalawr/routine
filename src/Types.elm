module Types exposing (..)

import Http exposing (Error(..))
import Date exposing (Date)
import Dom

type alias Model =
  { new : Maybe String
  , today : Maybe Date
  , routines : List Routine
  }

type alias Routine =
  { name : String
  , progress : List Date
  , id : Id
  , editing : Maybe String
  }

type alias TickResponse = 
  { id : Id
  , routine : Id
  , date : Date
  }

type alias Id =
  Int

type Message
  = IntentionToCreate
  | TypeName String
  | Now Date
  | All
  | AllResult (Result Error (List Routine))
  | Create String
  | CreateResult (Result Error Routine)
  | Delete Id
  | DeleteResult (Result Error Id)
  | Tick Id
  | TickResult (Result Error TickResponse)
  | Untick Id
  | UntickResult (Result Error Id)
  | IntentionToEdit Routine String
  | Edit Id String
  | EditSubmit Id String
  | EditResult (Result Error (Id, String))
  | CancelEdit Id
  | NoOp