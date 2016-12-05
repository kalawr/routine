module External.Focus exposing (focusOnto)

import Dom
import Task

import Types exposing (..)

focusOnto : String -> Cmd Message
focusOnto id =
  Task.attempt (\_ -> NoOp) (Dom.focus id)