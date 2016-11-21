module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date exposing (Date, Month(..))
import Date.Extra exposing (Interval(..))
import String
import Types exposing (..)

view : Model -> Html Message
view model =
  div []
  [ header model
  , div [class "container-narrow"]
    [ listGroup model
    ]
  ]


header : Model -> Html Message
header model =
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


listGroup : Model -> Html Message
listGroup model =
  div [class "list container-narrow ph-2"]
    (List.map (listItem model) model.routines)


listItem : Model -> Routine -> Html Message
listItem model routine =
  article [class "box-shadow mh-2-negative mb-1 pa-2 bg-white oh"]
  [ div [ class "cf"]
    [ listItemHeading routine
    , div [class "fr"]
      [ button [class "no-border pa-0", onClick (Delete routine.id)]
        [ i [class "icon-trash feather"] []
        ]
      ]
    ]
  , yearBlock model routine.progress
  , listItemButton model routine 
  ]


listItemHeading : Routine -> Html Message
listItemHeading routine =
  case routine.editing of
    Nothing ->
      h2 [onDoubleClick (IntentionToEdit routine (editId routine.id)), class "fl no-select pointer mb-1 mt-0 fw-thin font-lg bb-1 border-transparent"]
      [ text routine.name
      ]
    Just string ->
      Html.form [onSubmit (EditSubmit routine.id string), class "fl mb-1"]
      [ input
        [ type_ "text"
        , onInput (Edit routine.id)
        , value string
        , class "mb-half-negative pa-0 pb-half bb-1 border-light font-lg"
        , id (editId routine.id)
        ] []
      , button [type_ "submit", class "emerald border-1 font-sm uppercase fw-normal ml-half round-corners"] [text "Сохранить"]
      , button [type_ "button", class "border-1 font-sm uppercase fw-normal ml-half round-corners", onClick (CancelEdit routine.id)] [text "Отменить"]
      ]


editId : Id -> String
editId id =
  id
  |> toString
  |> (++) "edit-field-"


listItemButton : Model -> Routine -> Html Message
listItemButton model routine =
  let
    todayOk =
      todayTicked model.today routine.progress
  in
    div [class "flex flex-row mt-1"]
    [ button
      [ class "flex-1 no-border pa-half round-corners"
      , classList 
        [ ("bg-gray", (not todayOk))
        , ("bg-emerald", todayOk)
        , ("white", todayOk)
        ]
      , onClick (listItemButtonMessage routine.id todayOk)
      ]
      [ i [class "icon-check feather"] []
      ]
    ]


listItemButtonMessage : Id -> Bool -> Message
listItemButtonMessage id ticked =
  case ticked of
    True ->
      Untick id
    False ->
      Tick id


todayTicked : Maybe Date -> List Date -> Bool
todayTicked today ticks =
  case today of
    Just date ->
      ticks
      |> List.member (Date.Extra.floor Day date)
    Nothing ->
      False


year : Date -> List Date
year today =
  let
    y =
      Date.year today
  in
    Date.Extra.range Day 1
      (Date.Extra.fromParts  y Jan 1 0 0 0 0)
      today


yearMatches : List Date -> List Date -> List (Date, Bool)
yearMatches year ticks =
  List.map
    ( \day ->
      (day, dayInTicks ticks day)
    )
    year


dayInTicks : List Date -> Date -> Bool
dayInTicks ticks day =
  List.any
    ( \tick ->
      Date.Extra.equal tick day
    )
    ticks


yearBlock : Model -> List Date -> Html Message
yearBlock model progress =
  case model.today of
    Just today ->
      div [class "ticks cf"]
        (List.map
          yearItem
          (yearMatches (year today) progress))
    Nothing ->
      text ""


yearItem : (Date, Bool) -> Html Message
yearItem (date, attended) =
  span
  [ title (formatDate date)
  , class "tick fl"
  , classList 
    [ ("bg-emerald", attended)
    ]
  ]
  []


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