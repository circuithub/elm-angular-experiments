module Elmgular.Action where

import Json.Decode as D exposing (Decoder, (:=), andThen, succeed, fail)
import Json.Encode as E exposing (Value)

type alias AngularActions a = (Decoder a, Value)

action : a -> String -> (Decoder a, Value)
action v t =
  let decoder = ("tag" := D.string) `andThen`
                  \s -> case s of
                    t -> succeed v
                    _ -> fail ("unknown tag for Action : " ++ t)
      spec = E.object [("tag", E.string t)]
  in (decoder, spec)

