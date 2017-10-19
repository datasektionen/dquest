{-# LANGUAGE  OverloadedStrings #-}
module DQuest.Database  where

import Database.MongoDB    (Action, Document, Document, Value, Query, Selector, access,
                            close, connect, delete, exclude, find, insert,
                            host, insertMany, master, project, rest, findOne,
                            select, sort, (=:))
import Control.Monad.Trans (liftIO)

import System.Environment
import Data.Aeson.Bson
import Data.Maybe
import Data.Function
import Data.Functor

import DQuest.Data
import Datasektionen.Types

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

toData = (Aeson.fromJSON . Aeson.Object . toAeson)
toDBData a = toBson o
  where
    (Aeson.Object o) = Aeson.toJSON a


fuckErrors :: [Aeson.Result a] -> [a]
fuckErrors [] = []
fuckErrors ((Aeson.Success a):xs) = a : fuckErrors xs
fuckErrors (_:xs) = fuckErrors xs

questsBy :: Selector -> IO [Quest]
questsBy q = run $ do
  docs <- rest =<< find (select q bountyTable){sort = ["uploaded" =: (1::Int)]}
  pure $ fuckErrors $ fmap toData docs

activeQuests :: IO [Quest]
activeQuests = questsBy  ["closed" =: False]

closedQuests :: IO [Quest]
closedQuests = questsBy ["closed" =: True]

allQuests :: IO [Quest]
allQuests = questsBy []


insertQuest :: Quest -> Action IO Value
insertQuest = insert bountyTable . toDBData

{-
getHero :: KthID -> IO (Maybe Hero)
getHero kthID = run $ do
  maybeRes <- findOne ["kthid" =: kthID] userTable
  pure $ maybeRes >>= toAeson & Aeson.decode
-}
