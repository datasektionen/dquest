{-|
Author: Tomas Möre 2017


-}
{-# LANGUAGE  OverloadedStrings #-}
module DQuest.Database.Hero  where

import Database.MongoDB

import DQuest.Data
import qualified DQuest.Data.Hero as Hero

import Data.Text (Text)

import DQuest.Database.Util
import DQuest.Database.TableNames

getHero :: Text -> IO (Maybe Hero)
getHero kthID = run $ do
  maybeRes <- findOne (select ["kthid" =: kthID] userTable)
  pure $ maybeRes >>=  toData

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
