import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Types exposing (..)
import External.Create

-- STATE
init : (Model, Cmd Message)
init =
  initialModel
    ! []

initialModel : Model
initialModel =
  { new = ""
  , routines = []
  }

subscriptions : Model -> Sub Message
subscriptions _ =
  Sub.none

-- UPDATE

update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    NewName string ->
      { model | new = string }
        ! []

    CreateResult result ->
      case result of 
        Ok routine ->
          { model | routines = routine :: model.routines }
            ! []
        Err _ ->
          model
            ! []

    Create ->
      model
        ! [External.Create.create model]

-- VIEW

view : Model -> Html Message
view model =
  Html.form [onSubmit Create]
  [ input [type_ "text", value model.new, onInput NewName] []
  , button [type_ "submit"] [text "Create"]
  ]

-- WIRE UP

main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }