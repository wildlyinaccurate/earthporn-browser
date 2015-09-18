module Browser where

import Array
import Json.Decode as Json exposing ((:=))
import List exposing (length)
import Task

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Http


-- MODEL

type alias Model =
    { position : Int
    , posts : List Post
    }


type alias Post =
  { id : String
  , title : String
  , source : Image
  }


type alias Image =
  { url : String
  , width : Int
  , height : Int
  }


init : (Model, Effects Action)
init =
  ( Model 0 []
  , getPosts
  )


currentPost : Model -> Maybe Post
currentPost model =
  Array.get model.position (Array.fromList model.posts)


imageUrl : Maybe Post -> String
imageUrl maybePost =
  case maybePost of
    Just post -> post.source.url
    Nothing -> "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"


imageDescription : Maybe Post -> String
imageDescription maybePost =
  case maybePost of
    Just post -> post.title
    Nothing -> "Loading..."


-- UPDATE

type Action
  = PreviousPost
  | NextPost
  | LoadPosts (Maybe (List Post))


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    PreviousPost ->
        ( { model | position <- max 0 (model.position - 1) }
        , Effects.none
        )

    NextPost ->
        ( { model | position <- min (length model.posts) (model.position + 1) }
        , Effects.none
        )

    LoadPosts maybePosts ->
        ( { model | posts <- (Maybe.withDefault model.posts maybePosts) }
        , Effects.none
        )


-- VIEW

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
  let currentPosition = toString (model.position + 1)
      totalPosts = toString (length (model.posts))
  in
    div
      [ class "container" ]
      [ div
        [ class "image"
        , imgStyle (imageUrl (currentPost model))
        ]
        []

      , p
        [ class "image-description" ]
        [ text (imageDescription (currentPost model)) ]

      , div
        [ class "nav" ]
        [
          button
          [ class "nav--prev"
          , onClick address PreviousPost
          ]
          [ text "Previous Post" ]

        , span
          [ class "nav-position" ]
          [ text (currentPosition ++ " / " ++ totalPosts) ]

        , button
          [ class "nav--next"
          , onClick address NextPost
          ]
          [ text "Next Post" ]
        ]
      ]


imgStyle : String -> Attribute
imgStyle url =
  style
    [ "background-image" => ("url('" ++ url ++ "')")
    , "background-position" => "center"
    , "background-repeat" => "no-repeat"
    , "background-size" => "contain"
    ]


-- EFFECTS

getPosts : Effects Action
getPosts =
  Http.get redditDecoder "https://api.reddit.com/r/earthporn/hot"
    |> Task.toMaybe
    |> Task.map LoadPosts
    |> Effects.task


redditDecoder : Json.Decoder (List Post)
redditDecoder =
  Json.at ["data", "children"] (Json.list postDecoder)


postDecoder : Json.Decoder Post
postDecoder =
  Json.object3 Post
    (Json.at ["data", "id"] Json.string)
    (Json.at ["data", "title"] Json.string)
    (Json.at ["data", "preview", "images"] (Json.tuple1 identity imageDecoder))


imageDecoder : Json.Decoder Image
imageDecoder =
  Json.at ["source"] (Json.object3 Image
    ("url" := Json.string)
    ("width" := Json.int)
    ("height" := Json.int)
  )
