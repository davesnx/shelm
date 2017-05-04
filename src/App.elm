module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onEnter)
import List exposing (..)
import List.Extra exposing (..)
import Keyboard exposing (..)
import Debug


---- MODEL ----


type alias Model =
    { message : String
    , logo : String
    , history : List String
    , shellText : String
    , historyIndex : Int
    }


init : String -> ( Model, Cmd Msg )
init path =
    ( { message = "This app is has been created with create-elm-app"
      , logo = path
      , history =
            [ "create-react-app Typeform-frontend"
            , "rm -rf tf-dev-kit/typeform"
            , "ls -lsha"
            ]
      , shellText = ""
      , historyIndex = -1
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | Run String
    | Write String
    | Move KeyCode


run : Model -> String -> ( Model, Cmd Msg )
run model command =
    case command of
        "clear" ->
            ( { model
                | history = []
                , shellText = ""
                , historyIndex = -1
              }
            , Cmd.none
            )

        "sudo" ->
            Debug.log "sudo not allowed..."
                ( model, Cmd.none )

        "" ->
            ( model, Cmd.none )

        _ ->
            ( { model
                | history = command :: model.history
                , shellText = ""
                , historyIndex = -1
              }
            , Cmd.none
            )


get : Int -> List String -> String
get n list =
    List.Extra.getAt n list |> Maybe.withDefault ""


direction : Model -> Int -> ( Model, Cmd Msg )
direction model keycode =
    case keycode of
        38 ->
            ( { model
                | shellText =
                    get (model.historyIndex + 1) model.history
                , historyIndex =
                    Basics.min
                        (model.historyIndex + 1)
                        (List.length model.history)
              }
            , Cmd.none
            )

        40 ->
            ( { model
                | shellText =
                    get (model.historyIndex - 1) model.history
                , historyIndex = Basics.max (model.historyIndex - 1) -1
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Run command ->
            run model (String.trim command)

        Write command ->
            ( { model
                | shellText = command
              }
            , Cmd.none
            )

        Move keycode ->
            if isEmpty model.history then
                ( model, Cmd.none )
            else
                direction model keycode

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


shellHistoryItem : String -> Html Msg
shellHistoryItem value =
    li [] [ text value ]


shellHistory : List String -> Html Msg
shellHistory history =
    ul [ class "shell__history" ] <|
        List.reverse
            (List.map
                shellHistoryItem
                history
            )


view : Model -> Html Msg
view model =
    div [ class "wrapper" ]
        [ div [ class "app" ]
            [ shellHistory
                model.history
            , div
                [ class "shell__input" ]
                [ input
                    [ placeholder "Type a command here..."
                    , autofocus True
                    , value model.shellText
                    , onInput Write
                    , onEnter (Run model.shellText)
                    ]
                    []
                ]
            ]
        , div [ class "footer" ]
            [ img [ src model.logo ] []
            , p [] [ text model.message ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs Move



---- PROGRAM ----


main : Program String Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
