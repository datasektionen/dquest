{-# LANGUAGE  OverloadedStrings #-}
module DQuest.Database  where

import Database.MongoDB    (Action, Document, Document, Value, access,
                            close, connect, delete, exclude, find,
                            host, insertMany, master, project, rest,
                            select, sort, (=:))
import Control.Monad.Trans (liftIO)

import System.Environment
import Data.AesonBson
import Data.Maybe

import qualified Data.Aeson as Aeson

{-
Database sctructure:
-}


bountyTable = "bountys"
userTable = "heros"

run :: Action IO a -> IO a
run action = do
  url <- getEnv "MONGO_URL"
  pipe <- connect $ host url
  res <- access pipe master "dquest" action
  close pipe
  return res


questsBy :: Query -> IO [Quests]
questsBy q = run $ do
  docs <- find q bountytable {sort = ["uploaded" := 1]} >>= rest
  pure $ catToMaybe $ fmap (Aeson.decode . aesonify) docs

activeQuests :: IO [Quest]
activeQuests = questsBy ["closed" := False]

closedQuests :: IO [Quest]
closedQuests = questsBy ["closed" := True]

allQuests :: IO [Quest]
allQuests = questsBy []


insertQuest :: Quest -> Action IO Quest
insertQuest = run & Aeson.encode & bsonify & insert bountytable

getUser :: KthID -> Action IO (Maybe User)
getUser kthID = run $ do
  maybeRes <- findOne ["kthid" := kthID] userTable
  pure $ maybeRes >>= aesonify & Aeson.decode
