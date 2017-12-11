{-# LANGUAGE  OverloadedStrings #-}
module DQuest.Database.Quest  where

import Database.MongoDB

import Data.Aeson.Bson
import Data.Bson as Bson

import DQuest.Data

import DQuest.Data.Quest (QuestId)
import qualified DQuest.Data.Quest as Quest

import qualified Data.Aeson as Aeson

import Data.Text (Text)
import qualified Data.Text as Text
import Text.Read (readMaybe)

import Data.Maybe
import Data.Monoid

import DQuest.Database.Util
import DQuest.Database.TableNames

toQuest :: Bson.Document -> Maybe Quest
toQuest = toData . replaceLabel "_id" "id"

questIdToObjId :: QuestId -> Maybe Bson.ObjectId
questIdToObjId = readMaybe . Text.unpack

unsafeToObjectId :: QuestId -> Bson.ObjectId
unsafeToObjectId questId =
  maybe (error $ Text.unpack $ "Failed to parse objectid " <> questId) id (questIdToObjId questId)


questsBy :: Selector -> IO [Quest]
questsBy q = run $ do
  docs <- rest =<< find (select q bountyTable){sort = ["uploaded" =: (1::Int)]}
  pure $ catMaybes $ fmap toQuest docs

queryQuest :: Bson.ObjectId -> Action IO (Maybe Quest)
queryQuest questId = do
      c <- find (select ["_id" =: questId ] bountyTable)
      mDoc <- next c
      closeCursor c
      pure $ mDoc >>= toQuest

modifyQuest :: QuestId -> Modifier -> IO ()
modifyQuest questId modifier = run $ do
    modify selector modifier
  where
    selector = (select ["_id" =: unsafeToObjectId questId] bountyTable)
addAssigned :: QuestId -> Text -> IO Bool
addAssigned questId kthId = do
  mQuest <- getQuest questId
  print mQuest
  case mQuest of
    Nothing -> pure False
    Just q  -> do
      let newAssigned = ["assigned" =: kthId : Quest.assigned q]
      modifyQuest questId ["$set" =: newAssigned]
      pure True

removeAssigned :: QuestId -> Text -> IO ()
removeAssigned questId kthId =  do
  mQuest <- getQuest questId
  case mQuest of
    Nothing -> pure ()
    Just q ->
      modifyQuest questId ["assigned" =: filter (/= kthId) (Quest.assigned q)]

getQuest :: QuestId -> IO (Maybe Quest)
getQuest = run . queryQuest . unsafeToObjectId


activeQuests :: IO [Quest]
activeQuests = questsBy  ["closed" =: False]

closedQuests :: IO [Quest]
closedQuests = questsBy ["closed" =: True]

allQuests :: IO [Quest]
allQuests = questsBy []

newQuest :: Quest -> IO Quest
newQuest pq = run $ do
  val <- insert bountyTable insertData
  let (Aeson.String objID) = aesonifyValue val
  pure $ pq{Quest.id = objID}
  where
    bson = toDBData pq
    insertData = exclude ["id"] bson
