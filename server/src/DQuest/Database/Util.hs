{-|
Author: Tomas Möre

Description: Contains some functions for common functions for
modifying data and performing queries in the db

-}
{-# LANGUAGE OverloadedStrings #-}
module DQuest.Database.Util  where

import Database.MongoDB    (Action, Document, Document, Value, Query, Selector, access,
                            close, connect, delete, exclude, find, insert,
                            host, insertMany, master, project, rest, findOne,
                            select, sort, (=:))

import qualified Database.MongoDB  as  Mongo
import Control.Monad.Trans (liftIO)
import Control.Exception

import System.Environment
import Data.Aeson.Bson
import Data.Bson as Bson

import qualified Data.Aeson as Aeson

import Data.Maybe
import Control.Monad
import Data.List (stripPrefix)

defaultMongoURL = "127.0.0.1:27017"

mongoEnvName = "MONGO_URL"

toData :: (Aeson.FromJSON a) => Bson.Document -> Maybe a
toData bson =
  case bsonResult of
    Aeson.Success e -> Just e
    _ -> Nothing
  where
    bsonResult = Aeson.fromJSON $ Aeson.Object $ toAeson bson

toDBData :: Aeson.ToJSON a => a -> Bson.Document
toDBData a = toBson o
  where
    (Aeson.Object o) = Aeson.toJSON a

-- Simple BSON help function to replace a single lable
replaceLabel :: Bson.Label -> Bson.Label -> Bson.Document -> Bson.Document
replaceLabel _ _ [] = []
replaceLabel find replace (x@(k := v):xs)
  | k == find =  (replace := v) : xs
  | otherwise = x : replaceLabel find replace xs

run :: Action IO a -> IO a
run action = do
  maybeEnvUrl <- lookupEnv mongoEnvName
  liftIO $ when (isNothing maybeEnvUrl) $ putStrLn ("Mongodb env not found (" ++
                                        mongoEnvName  ++ ") " ++
                                        "defaulting to " ++ defaultMongoURL)
  let url = maybe defaultMongoURL (\ s -> fromMaybe s (stripPrefix "mongodb://" s)) maybeEnvUrl
      mongoHost = Mongo.readHostPort url

      connectionExceptionHandler :: IOError -> IO a
      connectionExceptionHandler e = do
        putStrLn "ERROR: MongoDB connection failed to open"
        print mongoHost
        throw e

  pipe <- connect mongoHost `catch` connectionExceptionHandler
  res <- access pipe master "dquest" action
  close pipe
  return res


  where
