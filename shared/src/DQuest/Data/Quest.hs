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

import DQuest.Data.QuestGiver (QuestGiverName, QuestGiver)
import qualified DQuest.Data.QuestGiver as QuestGiver

import DQuest.Data.Difficulty

type Tag = Text

data Quest = Quest
             { id          :: Text
             , title       :: Text
             , description :: Text
             , difficulty  :: Difficulty
             , questGiver  :: QuestGiverName
             , tags        :: [Tag]
             , issue       :: Maybe Text
             , comments    :: [Comment]
             , assigned    :: [KthID]
             , rewards     :: [(Quantity, Reward)]
             , creator     :: KthID
             , uploaded    :: UTCTime
             , closed      :: Maybe (UTCTime, [KthID])
             } deriving (Show,Read,Eq,Generic)
instance ToJSON Quest
instance FromJSON Quest

-- | This creates a ProtoQuest from a given quest, can be used for
-- editing the main parts of the
toProtoQuest :: Quest -> (ProtoQuest, Text)
toProtoQuest Quest{..} = (PQ.ProtoQuest title description issue questGiver difficulty rewards
                         , id)

fromProtoQuest :: KthID -> ProtoQuest -> IO Quest
fromProtoQuest creator pq = do
  currentTime <- getCurrentTime
  return $ Quest
    { id = mempty
    , title       = PQ.title pq
    , description = PQ.description pq
    , difficulty  = PQ.difficulty pq
    , questGiver  = PQ.questGiver pq
    , tags        = []
    , issue       = PQ.issue pq
    , comments    = []
    , assigned    = []
    , rewards     = PQ.rewards pq
    , creator     = creator
    , uploaded    = currentTime
    , closed      = Nothing
    }

updateWithProtoQuest :: Quest -> ProtoQuest -> Quest
updateWithProtoQuest q PQ.ProtoQuest{..} =
  q{ title = title
   , description = description
   , issue = issue
   , rewards = rewards
   }

dummy :: IO Quest
dummy = fromProtoQuest "tmore" PQ.empty
