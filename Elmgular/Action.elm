module Elmgular.Action ( Angular
                       , Argument
                       , make
                       , merge
                       , wrap
                       , make1
                       , make2
                       , make3
                       , argumentInt
                       , argumentFloat
                       , argumentBool
                       , argumentString
                       , maybe
                       ) where

import Json.Decode as D exposing (Decoder, (:=), andThen, succeed, fail, oneOf)
import Json.Encode as E exposing (Value)
import List as L exposing (map)

type alias Angular a = (Decoder a, Value)

make : String -> a -> Angular a
make t v =
  let decoder = ("tag" := D.string) `andThen`
                  \s -> case s of
                    t -> succeed v
                    _ -> fail ("unknown tag for Action : " ++ t)
      spec = E.object [("tag", E.string t)]
  in (decoder, spec)

merge : List (Angular a) -> Angular a
merge acts =
  let decoder = map fst acts |> oneOf
      spec = map snd acts |> E.list
  in (decoder, spec)

wrap : String -> (a -> b) -> Angular a -> Angular b
wrap t wrp inner =
  let decoder = ("tag" := D.string) `andThen`
                  \s -> case s of
                    t -> D.object1 wrp ("inner" := fst inner)
                    _ -> fail ("unknown tag for Action : " ++ t)
      spec = E.object [("tag", E.string t), ("inner", snd inner)]
  in (decoder, spec)

type alias Argument a = (ArgumentTag, Decoder a)

make1 : String -> (arg1 -> a) -> Argument arg1 -> Angular a
make1 t mk arg1 =
  let d1 = snd arg1
      a1 = fst arg1 |> showArgumentTag
      decoder = ("tag" := D.string) `andThen`
                  \s -> case s of
                    t -> ("args" := D.tuple1 mk d1)
                    _ -> fail ("unknown tag for Action : " ++ t)
      spec = E.object [ ("tag", E.string t)
                      , ("args", E.list [E.string a1])
                      ]
  in (decoder, spec)

make2 : String -> (arg1 -> arg2 -> a) -> Argument arg1 -> Argument arg2 -> Angular a
make2 t mk arg1 arg2 =
  let d1 = snd arg1
      a1 = fst arg1 |> showArgumentTag
      d2 = snd arg2
      a2 = fst arg2 |> showArgumentTag
      decoder = ("tag" := D.string) `andThen`
                  \s -> case s of
                    t -> ("args" := D.tuple2 mk d1 d2)
                    _ -> fail ("unknown tag for Action : " ++ t)
      spec = E.object [ ("tag", E.string t)
                      , ("args", E.list [E.string a1, E.string a2])
                      ]
  in (decoder, spec)

make3 : String -> (arg1 -> arg2 -> arg3 -> a) -> Argument arg1 -> Argument arg2 -> Argument arg3 -> Angular a
make3 t mk arg1 arg2 arg3 =
  let d1 = snd arg1
      a1 = fst arg1 |> showArgumentTag
      d2 = snd arg2
      a2 = fst arg2 |> showArgumentTag
      d3 = snd arg3
      a3 = fst arg3 |> showArgumentTag
      decoder = ("tag" := D.string) `andThen`
                  \s -> case s of
                    t -> ("args" := D.tuple3 mk d1 d2 d3)
                    _ -> fail ("unknown tag for Action : " ++ t)
      spec = E.object [ ("tag", E.string t)
                      , ("args", E.list [E.string a1, E.string a2, E.string a3])
                      ]
  in (decoder, spec)

argumentInt : Argument Int
argumentInt = (ArgumentTagInt, D.int)

argumentFloat : Argument Float
argumentFloat = (ArgumentTagFloat, D.float)

argumentString : Argument String
argumentString = (ArgumentTagString, D.string)

argumentBool : Argument Bool
argumentBool = (ArgumentTagBool, D.bool)

maybe : Argument a -> Argument (Maybe a)
maybe a = (ArgumentTagMaybe (fst a), D.maybe (snd a))

type ArgumentTag =  ArgumentTagInt
                   | ArgumentTagFloat
                   | ArgumentTagString
                   | ArgumentTagBool
                   | ArgumentTagMaybe ArgumentTag

showArgumentTag : ArgumentTag -> String
showArgumentTag t = case t of
        ArgumentTagInt      -> "ArgumentTagInt"
        ArgumentTagFloat    -> "ArgumentTagFloat"
        ArgumentTagString   -> "ArgumentTagString"
        ArgumentTagBool     -> "ArgumentTagBool"
        ArgumentTagMaybe a  -> "ArgumentTagMaybe " ++ showArgumentTag a
