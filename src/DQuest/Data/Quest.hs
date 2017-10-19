{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.Quest where

import Data.Map  (Map)

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import Data.Time.Clock (UTCTime, getCurrentTime)

import Datasektionen.Types
import DQuest.Data.ProtoQuest (ProtoQuest)
import qualified DQuest.Data.ProtoQuest as Proto
import DQuest.Data.Reward
import DQuest.Data.Comment (Comment)

data Quest = Quest
             { title       :: Text
             , description :: Text
             , issue       :: Maybe Text
             , comments    :: [Comment]
             , asigned     :: [KthID]
             , rewards     :: [Reward]
             , uploaded    :: UTCTime
             , closed      :: Maybe UTCTime
             , completedBy :: Maybe [KthID]
             } deriving (Show,Read,Eq,Generic)
instance ToJSON Quest
instance FromJSON Quest




fromProtoQuest :: ProtoQuest -> IO Quest
fromProtoQuest pq = do
  t <- getCurrentTime
  return $ Quest
    { title       = Proto.title pq
    , description = Proto.description pq
    , issue       = Proto.issue pq
    , rewards     = Proto.rewards pq
    , comments    = []
    , asigned     = []
    , uploaded    = t
    , closed      = Nothing
    , completedBy  = Nothing
    }
