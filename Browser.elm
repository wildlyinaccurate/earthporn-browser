module Browser where

import Http
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Json exposing ((:=))
import Task
import Effects exposing (Effects)
import Array


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
        ( { model | position <- min (List.length model.posts) (model.position + 1) }
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
  div []
    [ button [ onClick address PreviousPost ] [ text "<" ]
    , text ("Current position: " ++ (toString (model.position)))
    , text (" | Total posts: " ++ (toString (List.length (model.posts))))
    , div [ imgStyle (currentImg model) ] []
    , button [ onClick address NextPost ] [ text ">" ]
    ]


currentImg : Model -> String
currentImg model =
  let currentPost =
    Array.get model.position (Array.fromList model.posts)
  in
    case currentPost of
      Just post -> post.source.url

      Nothing -> "http://www.redditstatic.com/reddit404c.png"


imgStyle : String -> Attribute
imgStyle url =
  style
    [ "display" => "inline-block"
    , "width" => "200px"
    , "height" => "200px"
    , "background-position" => "center center"
    , "background-size" => "cover"
    , "background-image" => ("url('" ++ url ++ "')")
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
