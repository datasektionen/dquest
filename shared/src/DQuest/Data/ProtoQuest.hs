{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.ProtoQuest where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import DQuest.Data.Reward

data ProtoQuest = ProtoQuest
  { title      :: Text
  , description :: Text
  , issue      :: Maybe Text
  , rewards    :: [(Quantity, Reward)]
  } deriving (Show,Read,Eq,Generic)
instance ToJSON ProtoQuest
instance FromJSON ProtoQuest

empty :: ProtoQuest
empty = ProtoQuest
        { title = mempty
        , description = mempty
        , issue = Nothing
        , rewards = []
        }

dummy :: ProtoQuest
dummy = ProtoQuest
        { title = "Test quest"
        , description = "This is a test description"
        , issue = Nothing
        , rewards = []
        }
