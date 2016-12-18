module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Json.Decode

import Date.Extra exposing (Interval(..))
import Date exposing (Date, Month(..))
import Types exposing (..)


view : Model -> Html Message
view model =
  div []
  [ modal model
  , mainHeader model
  , div [class "container-narrow"]
    [ routines model
    ]
  ]


noElementWhatsoever : Html Message
noElementWhatsoever =
  text ""


modal : Model -> Html Message
modal model =
  case model.modal of
    Just config ->
      div [class "fixed stretch z-modal bg-transparent-white flex pa-2", onClick DismissModal]
      [ div [class "mxw-500 ma-auto pa-2 box-shadow bg-white", isolatedOnClick NoOp]
        [ text config.text
        , div [class "cf mt-2"]
          [ div [class "fr"]
            [ button [class "border-0 pa-half round-corners bg-light-gray", isolatedOnClick DismissModal] [text config.cancelText]
            , button [class "border-0 pa-half round-corners white bg-emerald ml-half", isolatedOnClick config.confirmMessage] [text config.confirmText]
            ]
          ]
        ]
      ]
    Nothing ->
      noElementWhatsoever


mainHeader : Model -> Html Message
mainHeader model =
  div [class "bg-white pv-1 mb-4 box-shadow"]
  [ div [class "container ph-2 flex flex-wrap flex-row flex-x-start flex-justify-between"]
    [ h1 [class "fw-thin mt-0 mb-1 font-lg"]
      [ text "Routines"
      ]
    , createGroup model
    ]
  ]


createGroup : Model -> Html Message
createGroup model =
  case model.new of
    Just string ->
      Html.form [class "flex flex-row flex-nowrap flex-x-end", onSubmit (Create string)]
      [ input 
        [ type_ "text"
        , class "input-reset pa-half bb-1 border-light"
        , value string
        , onInput TypeName
        , placeholder "Новая привычка"
        , id "create-input"
        , autocomplete False
        ] []
      , button [type_ "submit", class "emerald border-1 pa-half ml-1 round-corners"]
        [ text "Создать"
        ]
      ]

    Nothing ->
      Html.form [class "flex flex-row flex-nowrap flex-x-end", onSubmit IntentionToCreate]
      [ button [type_ "submit", class "emerald border-1 pa-half ml-1 round-corners"]
        [ text "Создать"
        ]
      ]


routines : Model -> Html Message
routines model =
  div [class "list container-narrow ph-2"]
    (List.map (routine model) model.routines)


routine : Model -> Routine -> Html Message
routine model routine =
  article [class "box-shadow mh-2-negative mb-1 pa-2 bg-white oh"]
  [ routineHeader model routine
  , routineCalendar model routine
  , routineButton model routine
  ]


yesterday : Date -> Date
yesterday date =
  Date.Extra.add Day -1 date


routineHeader : Model -> Routine -> Html Message
routineHeader model routine =
  header [class "flex flex-x-start"]
  [ routineTitle model routine
  , routineConfirmEdit model routine
  , routineCancelEdit model routine
  , routineMenu model routine
  ]


routineTitle : Model -> Routine -> Html Message
routineTitle model routine =
  case routine.editing of
    Just string ->
      Html.form [onSubmit (RenameSubmit routine.id string), class "mb-half flex-1"]
      [ input
        [ type_ "text"
        , onInput (Rename routine.id)
        , value string
        , class "pa-0 pb-half bb-1 border-light font-lg mr-half w-100"
        , id (editId routine.id)
        , autocomplete False
        ] []
      ]
    Nothing ->
      h2
      [ onDoubleClick (IntentionToRename routine (editId routine.id))
      , class "no-select pointer mb-1 mt-0 fw-thin font-lg bb-1 border-transparent flex-1"
      ]
      [ text routine.name
      ]


routineConfirmEdit : Model -> Routine -> Html Message
routineConfirmEdit model routine =
  case routine.editing of
    Just string ->
      button
      [ type_ "submit"
      , class " pa-0 tiny-button no-border"
      , onClick (RenameSubmit routine.id string)
      ]
      [ i [class "icon-check feather"] []
      ]
    Nothing ->
      noElementWhatsoever


routineCancelEdit : Model -> Routine -> Html Message
routineCancelEdit model routine =
  case routine.editing of
    Just _ ->
      button
      [ type_ "button"
      , class " pa-0 tiny-button no-border"
      , onClick (CancelRename routine.id)
      ]
      [ i [class "icon-cross feather"] []
      ]
    Nothing ->
      noElementWhatsoever


routineMenu : Model -> Routine -> Html Message
routineMenu model routine =
  let
    ticked =
      todayTicked (yesterday model.today) routine.progress
    showMenu =
      model.routineWithOpenMenu
      |> Maybe.map (\routine_ -> routine_.id == routine.id)
      |> Maybe.withDefault False
  in
    div [class "relative"]
    [ button [class "pa-0 tiny-button no-border", onClick (OpenMenu routine)]
      [ i [class "icon-menu feather"] []
      ]
    , ul [class "pa-0 ma-0 no-bullets box-shadow z-dropdown bg-white absolute top-100 right-0 font-sm", classList [("hidden", not showMenu)]]
      [ li [class "pv-half ph-1 bg-light-gray-on-hover changes pointer nowrap", onClick (Delete routine.id)] [text "Удалить"]
      , li [class "pv-half ph-1 bg-light-gray-on-hover changes pointer nowrap", onClick (routineButtonMessage routine.id (yesterday model.today) ticked)] [text "Отметить за вчерашний день"]
      ]
    ]


editId : Id -> String
editId id =
  id
  |> toString
  |> (++) "edit-field-"


routineButton : Model -> Routine -> Html Message
routineButton model routine =
  let
    ticked =
      todayTicked model.today routine.progress
  in
    div [class "flex flex-row mt-1"]
    [ button
      [ class "flex-1 no-border pa-half round-corners"
      , classList 
        [ ("bg-light-gray", (not ticked))
        , ("bg-emerald", ticked)
        , ("white", ticked)
        ]
      , onClick (routineButtonMessage routine.id model.today ticked)
      ]
      [ i [class "icon-check feather"] []
      ]
    ]


routineButtonMessage : Id -> Date -> Bool -> Message
routineButtonMessage id date ticked =
  case ticked of
    True ->
      Untick id date
    False ->
      Tick id date


todayTicked : Date -> List Date -> Bool
todayTicked today ticks =
  ticks
  |> List.member today


routineCalendar : Model -> Routine -> Html Message
routineCalendar model routine =
  model.today
  |> year
  |> List.map (\day -> (day, dayStatus routine.created routine.progress day))
  |> List.map yearItem
  |> div [class "ticks cf"]


year : Date -> List Date
year today =
  let
    y =
      Date.year today
  in
    Date.Extra.range Day 1
      (Date.Extra.fromParts  y Jan 1 0 0 0 0)
      (Date.Extra.add Day 1 today)


dayStatus : Date -> List Date -> Date -> TickState
dayStatus created tickedDays day =
  if Date.toTime created > Date.toTime day
  then
    BeforeCreated
  else
    if List.any (\tickedDay -> Date.Extra.equal day tickedDay) tickedDays
    then
      Ticked
    else
      NotTicked


yearItem : (Date, TickState) -> Html Message
yearItem (date, state) =
  let
    classes =
      case state of
        BeforeCreated ->
          "tick fl bg-light-gray"
        Ticked ->
          "tick fl bg-emerald tick--yes"
        NotTicked ->
          "tick fl bg-light-gray"
  in
    span [title (formatDate date), class classes] []


formatDate : Date -> String
formatDate date =
  let
    parts =
      [ Date.day date
      , Date.Extra.monthNumber date
      , Date.year date
      ]
  in
    parts
    |> List.map ensurePrecedingZero
    |> String.join "."


ensurePrecedingZero : Int -> String
ensurePrecedingZero n =
  if n < 10
  then
    toString n
    |> (++) "0"
  else
    toString n


-- CUSTOM EVENTS


isolatedOnClick : Message -> Attribute Message
isolatedOnClick message =
  onWithOptions
    "click"
    { stopPropagation = True
    , preventDefault = False
    }
    (Json.Decode.succeed message)