import Html
import Date exposing (Date)
import Date.Extra exposing (Interval(..))
import Time exposing (Time)

import Types exposing (..)
import External.Create
import External.All
import External.Delete
import External.Tick
import External.Untick
import External.Edit
import External.Focus
import View exposing (..)
import Task
import Mouse

-- STATE

init : Time -> (Model, Cmd Message)
init time =
  let
    date =
      time
      |> Date.fromTime
      |> Date.Extra.floor Day
  in
    initialModel date
      ! [ External.All.all
        ]

initialModel : Date -> Model
initialModel date =
  { new = Nothing
  , modal = Nothing
  , today = date
  , routines = []
  , routineWithOpenMenu = Nothing
  }

subscriptions : Model -> Sub Message
subscriptions model =
  Sub.batch
  [ Time.every Time.minute TimeElapsed
  , dropdownCloseSubscription model
  ]

dropdownCloseSubscription : Model -> Sub Message
dropdownCloseSubscription model =
  case model.routineWithOpenMenu of
    Just _ ->
      Mouse.clicks (\_ -> Blur)
    Nothing ->
      Sub.none

deleteConfirmation : Id -> ModalConfig
deleteConfirmation id =
  ModalConfig
    "Вы на самом деле хотите удалить эту привычку? Данные, связанные с ней, будут утрачены."
    "Не удалять"
    "Удалить"
    (DeleteConfirm id)

-- UPDATE

update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    IntentionToCreate ->
      { model | new = Just ""}
        ! [External.Focus.focusOnto "create-input"]

    TypeName string ->
      { model | new = Just string }
        ! []

    All ->
      model
        ! [External.All.all]

    AllResult result ->
      case result of
        Ok list ->
          { model | routines = list }
            ! []
        Err _ ->
          model
            ! []

    Create string ->
      case string of
        "" ->
          { model | new = Nothing }
            ! []
        _ ->
          model
            ! [External.Create.create string]

    CreateResult result ->
      case result of 
        Ok routine ->
          { model 
            | routines = routine :: model.routines
            , new = Nothing
          } ! []
        Err _ ->
          model
            ! []

    Delete id ->
      { model | modal = Just (deleteConfirmation id) }
        ! []

    DeleteConfirm id ->
      { model | modal = Nothing }
        ! [External.Delete.delete id]

    DeleteResult result ->
      case result of
        Ok id ->
          { model | routines = model.routines |> removeRoutine id }
            ! []
        Err _ ->
          model
            ! []

    Tick id date ->
      model
        ! [External.Tick.tick id date]

    TickResult result ->
      case result of 
        Ok (id, date) ->
          { model | routines = model.routines |> addTick id date }
            ! []
        Err _ ->
          model
            ! []

    Untick id date ->
      model
        ! [External.Untick.untick id date]

    UntickResult result ->
      case result of
        Ok (id, date) ->
          { model | routines = model.routines |> removeTick date id }
            ! []
        Err _ ->
          model
            ! []

    IntentionToRename routine elementId ->
      { model | routines = model.routines |> renameRoutine routine.id routine.name }
        ! [External.Focus.focusOnto elementId]

    Rename id name ->
      { model | routines = model.routines |> renameRoutine id name }
        ! []

    RenameSubmit id name ->
      model
        ! [External.Edit.edit id name]

    RenameResult result ->
      case result of
        Ok (id, name) ->
          { model | routines = model.routines |> finalizeRename id name }
            ! []
        Err _ ->
          model
            ! []

    CancelRename id ->
      { model | routines = model.routines |> cancelRename id }
        ! []

    NoOp ->
      model
        ! []

    DismissModal ->
      { model | modal = Nothing }
       ! []

    OpenMenu routine ->
      { model | routineWithOpenMenu = Just routine }
        ! []

    TimeElapsed _ ->
      model
        ! [Task.perform DateArrived Date.now]

    DateArrived date ->
      { model | today = date |> Date.Extra.floor Day }
       ! []

    Blur ->
      { model | routineWithOpenMenu = Nothing }
        ! []

-- UPDATE HELPERS

removeRoutine : Id -> List Routine -> List Routine
removeRoutine id routines =
  routines
  |> List.filter (\x -> x.id /= id)
    

addTick : Id -> Date -> List Routine -> List Routine
addTick id date routines =
  routines
  |> List.map
    (\routine ->
      if routine.id == id
      then
        { routine | progress = date :: routine.progress }
      else
        routine
    )

removeTick : Date -> Id -> List Routine -> List Routine
removeTick date id routines =
  routines
  |> List.map
    (\routine ->
      if routine.id == id
      then
        { routine
          | progress = 
              List.filter
                (\tick ->
                  tick /= Date.Extra.floor Day date
                )
                routine.progress
        }
      else
        routine
    )

renameRoutine : Id -> String -> List Routine -> List Routine
renameRoutine id string routines =
  routines
  |> List.map
    (\routine ->
      if routine.id == id
      then
        { routine | editing = Just string }
      else
        routine
    )

finalizeRename : Id -> String -> List Routine -> List Routine
finalizeRename id name routines =
  routines
  |> List.map
    (\routine ->
      if routine.id == id
      then
        { routine
          | name = name
          , editing = Nothing
        }
      else
        routine
    )

cancelRename : Id -> List Routine -> List Routine
cancelRename id routines =
  routines
  |> List.map
    (\routine -> 
      if routine.id == id
      then
        { routine | editing = Nothing }
      else
        routine
    )

-- WIRE UP

main =
  Html.programWithFlags
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }