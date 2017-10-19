{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.Quest where

import Data.Map  (Map)

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import Data.Time.Clock (UTCTime)

import Datasektionen.Types
import Dquest.Data.ProtoQuest


data Quest = Quest
             { title       :: Text
             , description :: Text
             , issue       :: Maybe Text
             , comments    :: [(Text, Text)]
             , asgined     :: [KthID]
             , rewards     :: [Reward]
             , uploaded    :: UTCTime
             , closed      :: Maybe UTCTime
             , completedBy :: Maybe KthID
             } deriving (Show,Read,Eq,Generic)
instance ToJSON Quest
instance FromJSON Quest




fromProtoQuest
