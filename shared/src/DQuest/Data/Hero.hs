{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module DQuest.Data.Hero where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import Data.Time.Clock (UTCTime)

import DQuest.Data.Reward
import Data.List

import Datasektionen.Types

type Username = Text
type ID = KthID

data Hero = Hero
  { kthid :: KthID
  , alias :: Username
  , lastVisit :: UTCTime
  , backpack  :: [Reward]
  } deriving (Show,Read,Eq,Generic)
instance ToJSON Hero
instance FromJSON Hero


totalEXP :: Hero -> EXP
totalEXP = maybe 0 (\ (XP n) -> n) .
           find (\ r -> case r of XP _ -> True; _ -> False) .
           backpack

level :: Hero -> Level
level =  (`div`100) . totalEXP
