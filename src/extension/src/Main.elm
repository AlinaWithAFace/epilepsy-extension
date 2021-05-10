module Main exposing (..)

import Browser
import Html exposing (Html, text, pre)
import Http
import Json.Decode exposing (Decoder, field, string)


main = Browser.element
  { init = init 
  , update = update
  , subscriptions = subscriptions
  , view = view
  }


type Model
  = Failure Http.Error
  | Loading
  | Success String

init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
    { url = "http://127.0.0.1:5000/api/videos/vid/4jXEuIHY9ic"
    , expect = Http.expectJson GotText decoder
    }
  )

decoder : Decoder String
decoder =
  field "video_title" string

type Msg
  = GotText (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText (Ok fullText) ->
      (Success fullText, Cmd.none)
    GotText (Err e) ->
      (Failure e, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  case model of
    Failure e ->
      text (Debug.toString e)
    Loading ->
      text "Loading"
    Success fullText ->
      pre [] [ text fullText ]
