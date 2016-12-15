module Types exposing (..)

import Http exposing (Error(..))
import Date exposing (Date)
import Time exposing (Time)

type alias Model =
  { new : Maybe String
  , modal : Maybe ModalConfig
  , today : Date
  , routines : List Routine
  }

type alias Routine =
  { name : String
  , created : Date
  , progress : List Date
  , id : Id
  , editing : Maybe String
  , menuOpen : Bool
  }

type alias Id =
  Int

type Message
  = IntentionToCreate
  | TypeName String
  | All
  | AllResult (Result Error (List Routine))
  | Create String
  | CreateResult (Result Error Routine)
  | Delete Id
  | DeleteConfirm Id
  | DeleteResult (Result Error Id)
  | Tick Id Date
  | TickResult (Result Error (Id, Date))
  | Untick Id Date
  | UntickResult (Result Error (Id, Date))
  | IntentionToRename Routine String
  | Rename Id String
  | RenameSubmit Id String
  | RenameResult (Result Error (Id, String))
  | CancelRename Id
  | DismissModal
  | ToggleMenu Id
  | NoOp
  | TimeElapsed Time
  | DateArrived Date

type alias ModalConfig =
  { text : String
  , cancelText : String
  , confirmText : String
  , confirmMessage : Message
  }

type TickState 
  = BeforeCreated
  | Ticked
  | NotTicked