{-# LANGUAGE  OverloadedStrings #-}
module DQuest.Database  where

import Database.MongoDB    (Action, Document, Document, Value, Query, Selector, access,
                            close, connect, delete, exclude, find, insert,
                            host, insertMany, master, project, rest, findOne,
                            select, sort, (=:))

import qualified Database.MongoDB  as  Mongo
import Control.Monad.Trans (liftIO)

import System.Environment
import Data.Aeson.Bson
import Data.Bson as Bson

import DQuest.Data
import qualified DQuest.Data.ProtoQuest as PQ
import qualified DQuest.Data.Quest as Quest
import qualified DQuest.Data.Hero as Hero
import qualified Data.Aeson as Aeson

import Data.Text (Text)
import qualified Data.Text as Text

import qualified Data.Char as Char

import Data.Maybe
import Control.Monad
import Data.List (stripPrefix)
{-
Database sctructure:
-}


bountyTable = "quests"
userTable = "heroes"

-- Urlstring for development purposes
defaultMongoURL = "127.0.0.1:27017"

mongoEnvName = "MONGO_URL"

run :: Action IO a -> IO a
run action = do
  maybeEnvUrl <- lookupEnv mongoEnvName
  liftIO $ when (isNothing maybeEnvUrl) $ putStrLn ("Mongodb env not found (" ++
                                        mongoEnvName  ++ ") " ++
                                        "defaulting to " ++ defaultMongoURL)
  let url = maybe defaultMongoURL (\ s -> fromMaybe s (stripPrefix "mongodb://" s)) maybeEnvUrl
      mongoHost = Mongo.readHostPort url
  pipe <- connect mongoHost
  res <- access pipe master "dquest" action
  close pipe
  return res

toData :: (Aeson.FromJSON a) => Bson.Document -> Aeson.Result a
toData = Aeson.fromJSON . Aeson.Object . toAeson

toDBData a = toBson o
  where
    (Aeson.Object o) = Aeson.toJSON a


fuckErrors :: [Aeson.Result a] -> [a]
fuckErrors [] = []
fuckErrors ((Aeson.Success a):xs) = a : fuckErrors xs
fuckErrors (_:xs) = fuckErrors xs

-- Simple BSON help function to replace a single lable
replaceLabel :: Bson.Label -> Bson.Label -> Bson.Document -> Bson.Document
replaceLabel _ _ [] = []
replaceLabel find replace (x@(k := v):xs)
  | k == find =  (replace := v) : xs
  | otherwise = x : replaceLabel find replace xs

questsBy :: Selector -> IO [Quest]
questsBy q = run $ do
  docs <- rest =<< find (select q bountyTable){sort = ["uploaded" =: (1::Int)]}
  let correctedID = fmap (replaceLabel "_id" "id") docs
  pure $ fuckErrors $ fmap toData correctedID

activeQuests :: IO [Quest]
activeQuests = questsBy  ["closed" =: False]

closedQuests :: IO [Quest]
closedQuests = questsBy ["closed" =: True]

allQuests :: IO [Quest]
allQuests = questsBy []

newQuest :: Quest -> IO Quest
newQuest pq = run $ do
  val <- insert bountyTable insertData
  liftIO $ print val
  let (Aeson.String objID) = aesonifyValue val
  pure $ pq{Quest.id = objID}
  where
    bson = toDBData pq
    insertData = exclude ["id"] bson

getHero :: Text -> IO (Maybe Hero)
getHero kthID = run $ do
  maybeRes <- findOne (select ["kthid" =: kthID] userTable)
  pure $ maybeRes >>= resultToMaybe . toData
  where
    resultToMaybe (Aeson.Error _) = Nothing
    resultToMaybe (Aeson.Success a) = Just a


insertHero :: Hero -> IO Hero
insertHero h = do
  mHero  <- getHero (Hero.kthid h)
  case mHero of
    Just a -> pure a
    Nothing -> run $ do
      insert userTable (toDBData h)
      pure h

-- | Tries to find a hero by its kthid, if it doesn't exit it creates
-- a new one and inserts it into the db
findOrInsertHero :: Text -> IO Hero
findOrInsertHero kthid = do
  mHero <- getHero kthid
  case mHero of
    Just a -> pure a
    Nothing -> do
      h <- Hero.blankHero kthid
      run $ do
        insert userTable (toDBData h)
        pure h
