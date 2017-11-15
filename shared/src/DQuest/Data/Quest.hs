{-# LANGUAGE OverloadedStrings, DeriveGeneric, RecordWildCards #-}
module DQuest.Data.Quest where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import Data.Time.Clock (UTCTime, getCurrentTime)

import Datasektionen.Types
import DQuest.Data.ProtoQuest (ProtoQuest)
import qualified DQuest.Data.ProtoQuest as PQ
import DQuest.Data.Reward
import DQuest.Data.Comment (Comment)

type Tag = Text

data Quest = Quest
             { title       :: Text
             , description :: Text
             , tags        :: [Tag]
             , issue       :: Maybe Text
             , comments    :: [Comment]
             , assigned    :: [KthID]
             , rewards     :: [(Quantity, Reward)]
             , uploaded    :: UTCTime
             , closed      :: Maybe (UTCTime, [KthID])
             , id          :: Text
             } deriving (Show,Read,Eq,Generic)
instance ToJSON Quest
instance FromJSON Quest

-- | This creates a ProtoQuest from a given quest, can be used for
-- editing the main parts of the
toProtoQuest :: Quest -> (ProtoQuest, Text)
toProtoQuest Quest{..} = (PQ.ProtoQuest title description issue rewards
                         , id)


fromProtoQuest :: ProtoQuest -> IO Quest
fromProtoQuest pq = do
  t <- getCurrentTime
  return $ Quest
    { title       = PQ.title pq
    , description = PQ.description pq
    , issue       = PQ.issue pq
    , rewards     = PQ.rewards pq
    , comments    = []
    , assigned    = []
    , uploaded    = t
    , closed      = Nothing
    , id          = mempty
    }

dummy :: IO Quest
dummy = fromProtoQuest PQ.dummy
