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
import View exposing (..)
import Dom
import Task

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
  , today = Nothing
  , routines = []
  }

subscriptions : Model -> Sub Message
subscriptions _ =
  Sub.none

-- UPDATE

update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    IntentionToCreate ->
      { model | new = Just ""}
        ! [Task.attempt (\_ -> NoOp) (Dom.focus "create-input")]

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
      model
        ! [External.Delete.delete id]

    DeleteResult result ->
      case result of
        Ok id ->
          { model | routines = removeRoutine model.routines id }
            ! []
        Err _ ->
          model
            ! []

    Tick id ->
      model
        ! [External.Tick.tick id]

    TickResult result ->
      case result of 
        Ok tick ->
          { model | routines = addTick model.routines tick }
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
          { model | routines = removeTick model.routines model.today id }
            ! []
        Err _ ->
          model
            ! []

    Now date ->
      { model | today = Just date }
        ! []

    IntentionToEdit routine elementId ->
      { model | routines = editRoutine routine.id routine.name model.routines }
        ! [Task.attempt (\_ -> NoOp) (Dom.focus elementId) ]

    Edit id string ->
      { model | routines = editRoutine id string model.routines }
        ! []

    EditSubmit id name ->
      model
        ! [External.Edit.edit id name]

    EditResult result ->
      case result of
        Ok (id, name) ->
          { model | routines = finalizeEdit id name model.routines }
            ! []
        Err _ ->
          model
            ! []

    CancelEdit id ->
      { model | routines = model.routines |> cancelEdit id }
        ! []

    NoOp ->
      model
        ! []

-- UPDATE HELPERS

removeRoutine : List Routine -> Id -> List Routine
removeRoutine list id =
  List.filter
    (\x -> x.id /= id)
    list

addTick : List Routine -> TickResponse -> List Routine
addTick list tick =
  List.map
    (\routine ->
      if routine.id == tick.routine
      then
        { routine | progress = tick.date :: routine.progress }
      else
        routine
    )
    list

removeTick : List Routine -> Maybe Date -> Id -> List Routine
removeTick routines today id =
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

editRoutine : Id -> String -> List Routine -> List Routine
editRoutine id string routines =
  List.map
    (\routine ->
      if routine.id == id
      then
        { routine | editing = Just string }
      else
        routine
    )
    routines

finalizeEdit : Id -> String -> List Routine -> List Routine
finalizeEdit id name routines =
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

cancelEdit : Id -> List Routine -> List Routine
cancelEdit id routines =
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