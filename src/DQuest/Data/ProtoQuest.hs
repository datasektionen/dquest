{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.ProtoQuests where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import DQuest.Data.Reward

data ProtoQuest = ProtoQuest
  { title      :: Text
  , desciption :: Text
  , issue      :: Maybe Text
  , rewards    :: [Reward]
  } deriving (Show,Read,Eq,Generic)
instance ToJSON ProtoQuest
instance FromJSON ProtoQuest
