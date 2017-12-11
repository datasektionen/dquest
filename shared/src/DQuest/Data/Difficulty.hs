{-|
Author: Tomas Möre 2017
-}
{-# LANGUAGE OverloadedStrings, DeriveGeneric, RecordWildCards #-}
module DQuest.Data.Difficulty where

import GHC.Generics
import Data.Aeson

import Data.String
import Data.Map (Map)
import qualified Data.Map as Map

data Difficulty = VeryEasy
                | Easy
                | Medium
                | Hard
                | VeryHard
                | RIP
                deriving (Show,Read,Eq,Generic, Ord)
instance ToJSON Difficulty
instance FromJSON Difficulty


scale :: [Difficulty]
scale = [ VeryEasy
        , Easy
        , Medium
        , Hard
        , VeryHard
        , RIP]


simpleTextRep :: IsString s => Difficulty -> s
simpleTextRep VeryEasy = "Very easy"
simpleTextRep Easy     = "Easy"
simpleTextRep Medium   = "Medium"
simpleTextRep Hard     = "Hard"
simpleTextRep VeryHard = "Very hard"
simpleTextRep RIP      = "RIP"


textAList :: IsString s => [(Difficulty, s)]
textAList = fmap (\d -> (d, simpleTextRep d)) scale

textMap :: IsString s => Map Difficulty s
textMap = Map.fromList textAList

standardHexColor :: IsString s => Difficulty -> s
standardHexColor VeryEasy = "#555555"
standardHexColor Easy = "#226622"
standardHexColor Medium = "#666622"
standardHexColor Hard = "#664422"
standardHexColor VeryHard = "#662222"
standardHexColor RIP = "#222222"
