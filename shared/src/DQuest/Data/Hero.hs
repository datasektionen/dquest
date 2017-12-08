{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module DQuest.Data.Hero where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import Data.Time.Clock (UTCTime, getCurrentTime )

import DQuest.Data.Reward
import Data.List

import Datasektionen.Types

type Username = Text
type ID = KthID

data Hero = Hero
  { kthid :: KthID
  , alias :: Username
  , lastVisit :: UTCTime
  , backpack  :: [(Quantity, Reward)]
  } deriving (Show,Read,Eq,Generic)
instance ToJSON Hero
instance FromJSON Hero


findReward :: Reward -> Hero -> Maybe (Quantity, Reward)
findReward requestedReward =
  find (\ (_,r) -> if requestedReward == r
                   then True
                   else False) .
  backpack

totalEXP :: Hero -> EXP
totalEXP = maybe 0 fst . findReward XP

level :: Hero -> Level
level =  (`div`100) . totalEXP


blankHero :: Text -> IO Hero
blankHero id = do
  t <- getCurrentTime
  pure $ Hero
    { kthid = id
    , alias = id
    , lastVisit = t
    , backpack = []
    }
