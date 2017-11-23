{-|
Author: Tomas Möre 2017
-}
{-# LANGUAGE OverloadedStrings, DeriveGeneric, RecordWildCards #-}
module DQuest.Data.Difficulty where

import GHC.Generics
import Data.Aeson

data Difficulty = VeryEasy
                | Easy
                | Medium
                | Hard
                | VeryHard
                | RIP
                deriving (Show,Read,Eq,Generic, Ord)
instance ToJSON Difficulty
instance FromJSON Difficulty


difficulties :: [Difficulty]
difficulties = [VeryEasy
               ,Easy
               ,Medium
               ,Hard
               ,VeryHard
               ,RIP]
