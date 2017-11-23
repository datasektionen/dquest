{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.ProtoQuest where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import DQuest.Data.Reward
import DQuest.Data.QuestGiver (QuestGiverName)

import DQuest.Data.Difficulty

data ProtoQuest = ProtoQuest
  { title      :: Text
  , description :: Text
  , issue      :: Maybe Text
  , questGiver :: QuestGiverName
  , difficulty :: Difficulty
  , rewards    :: [(Quantity, Reward)]
  } deriving (Show,Read,Eq,Generic)
instance ToJSON ProtoQuest
instance FromJSON ProtoQuest

empty :: ProtoQuest
empty = ProtoQuest
        { title = mempty
        , description = mempty
        , issue = Nothing
        , questGiver = "crash'n bränn"
        , difficulty = Medium
        , rewards = []
        }
