import Html
import Date exposing (Date)
import Date.Extra exposing (Interval(..))

import Types exposing (..)
import External.Create
import External.All
import External.Delete
import External.Tick
import External.Untick
import External.Edit
import External.Now
import External.Focus
import View exposing (..)

-- STATE

init : (Model, Cmd Message)
init =
  initialModel
    ! [ External.Now.now
      , External.All.all
      ]

initialModel : Model
initialModel =
  { new = Nothing
  , modal = Nothing
  , today = Nothing
  , routines = []
  }

subscriptions : Model -> Sub Message
subscriptions _ =
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

    Tick id ->
      model
        ! [External.Tick.tick id]

    TickResult result ->
      case result of 
        Ok (id, date) ->
          { model | routines = model.routines |> addTick id date }
            ! []
        Err _ ->
          model
            ! []

    Untick id ->
      model
        ! [External.Untick.untick id]

    UntickResult result ->
      case result of
        Ok id ->
          { model | routines = model.routines |> removeTick model.today id }
            ! []
        Err _ ->
          model
            ! []

    Now date ->
      { model | today = Just date }
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

-- UPDATE HELPERS

removeRoutine : Id -> List Routine -> List Routine
removeRoutine id list =
  List.filter
    (\x -> x.id /= id)
    list

addTick : Id -> Date -> List Routine -> List Routine
addTick id date list =
  List.map
    (\routine ->
      if routine.id == id
      then
        { routine | progress = date :: routine.progress }
      else
        routine
    )
    list

removeTick : Maybe Date -> Id -> List Routine -> List Routine
removeTick today id routines =
  case today of
    Just date ->
      List.map
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
        routines
    Nothing ->
      routines

renameRoutine : Id -> String -> List Routine -> List Routine
renameRoutine id string routines =
  List.map
    (\routine ->
      if routine.id == id
      then
        { routine | editing = Just string }
      else
        routine
    )
    routines

finalizeRename : Id -> String -> List Routine -> List Routine
finalizeRename id name routines =
  List.map
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
    routines

cancelRename : Id -> List Routine -> List Routine
cancelRename id routines =
  List.map
    (\routine -> 
      if routine.id == id
      then
        { routine | editing = Nothing }
      else
        routine
    )
    routines

-- WIRE UP

main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }