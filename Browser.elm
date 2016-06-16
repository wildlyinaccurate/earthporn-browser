module Browser exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json exposing ((:=))
import Keyboard exposing (KeyCode)
import List exposing (length)
import Task


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


init : ( Model, Cmd Msg )
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
        Just post ->
            post.source.url

        Nothing ->
            "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"


imageDescription : Maybe Post -> String
imageDescription maybePost =
    case maybePost of
        Just post ->
            post.title

        Nothing ->
            "Loading..."


previousPosition : Model -> Int
previousPosition model =
    max 0 (model.position - 1)


nextPosition : Model -> Int
nextPosition model =
    min ((length model.posts) - 1) (model.position + 1)



-- UPDATE


type Msg
    = PreviousPost
    | NextPost
    | FirstPost
    | LastPost
    | KeyPress KeyCode
    | LoadPostsSucceed (List Post)
    | LoadPostsFail Http.Error


type ArrowKey
    = UpArrow
    | DownArrow
    | LeftArrow
    | RightArrow


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LoadPostsSucceed posts ->
            ( { model | posts = posts }
            , Cmd.none
            )

        LoadPostsFail _ ->
            ( model, Cmd.none )

        PreviousPost ->
            ( { model | position = previousPosition model }
            , Cmd.none
            )

        NextPost ->
            ( { model | position = nextPosition model }
            , Cmd.none
            )

        FirstPost ->
            ( { model | position = 0 }
            , Cmd.none
            )

        LastPost ->
            ( { model | position = (length model.posts) - 1 }
            , Cmd.none
            )

        KeyPress code ->
            case arrowKey code of
                Just LeftArrow ->
                    update PreviousPost model

                Just RightArrow ->
                    update NextPost model

                Just DownArrow ->
                    update FirstPost model

                Just UpArrow ->
                    update LastPost model

                Nothing ->
                    ( model
                    , Cmd.none
                    )


arrowKey : KeyCode -> Maybe ArrowKey
arrowKey code =
    case code of
        38 ->
            Just UpArrow

        40 ->
            Just DownArrow

        37 ->
            Just LeftArrow

        39 ->
            Just RightArrow

        otherwise ->
            Nothing



-- VIEW


(=>) =
    (,)


view : Model -> Html Msg
view model =
    let
        currentPosition =
            toString (model.position + 1)

        totalPosts =
            toString (length (model.posts))
    in
        div [ class "container" ]
            [ div
                [ class "image"
                , imgStyle (imageUrl (currentPost model))
                ]
                []
            , p [ class "image-description" ]
                [ text (imageDescription (currentPost model)) ]
            , a
                [ class "btn btn--prev"
                , href "#"
                , onClick PreviousPost
                ]
                []
            , span [ class "position" ]
                [ text (currentPosition ++ " / " ++ totalPosts) ]
            , a
                [ class "btn btn--next"
                , href "#"
                , onClick NextPost
                ]
                []
            ]


currentImgUrl : Model -> String
currentImgUrl model =
    let
        currentPost =
            Array.get model.position (Array.fromList model.posts)
    in
        case currentPost of
            Just post ->
                post.source.url

            Nothing ->
                "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"


imgStyle : String -> Attribute msg
imgStyle url =
    style
        [ "background-image" => ("url('" ++ url ++ "')")
        , "background-position" => "center"
        , "background-repeat" => "no-repeat"
        , "background-size" => "contain"
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.ups KeyPress



-- HTTP


getPosts : Cmd Msg
getPosts =
    let
        url =
            "https://api.reddit.com/r/earthporn/hot"
    in
        Task.perform LoadPostsFail LoadPostsSucceed (Http.get redditDecoder url)


redditDecoder : Json.Decoder (List Post)
redditDecoder =
    Json.at [ "data", "children" ] (Json.list postDecoder)


postDecoder : Json.Decoder Post
postDecoder =
    Json.object3 Post
        (Json.at [ "data", "id" ] Json.string)
        (Json.at [ "data", "title" ] Json.string)
        (Json.at [ "data", "preview", "images" ] (Json.tuple1 identity imageDecoder))


imageDecoder : Json.Decoder Image
imageDecoder =
    Json.at [ "source" ]
        (Json.object3 Image
            ("url" := Json.string)
            ("width" := Json.int)
            ("height" := Json.int)
        )
