module Types exposing (..)

import Http exposing (Error(..))
import Date exposing (Date)

type alias Model =
  { new : Maybe String
  , modal : Maybe ModalConfig
  , today : Maybe Date
  , routines : List Routine
  }

type alias Routine =
  { name : String
  , progress : List Date
  , id : Id
  , editing : Maybe String
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
  | DeleteConfirm Id
  | DeleteResult (Result Error Id)
  | Tick Id
  | TickResult (Result Error (Id, Date))
  | Untick Id
  | UntickResult (Result Error Id)
  | IntentionToRename Routine String
  | Rename Id String
  | RenameSubmit Id String
  | RenameResult (Result Error (Id, String))
  | CancelRename Id
  | DismissModal
  | NoOp

type alias ModalConfig =
  { text : String
  , cancelText : String
  , confirmText : String
  , confirmMessage : Message
  }