module External.Now exposing (now)

import Date
import Task exposing (..)
import Types exposing (..)

now =
  perform Now Date.now