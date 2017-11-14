{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified DQuest.Data.Dummies as Dummy
import DQuest.Data.Quest (Quest)

import Display
import Admin
import ServerApi
import Views

import Reflex.Dom

import qualified Data.Text as Text

main :: IO ()
main = mainWidget $ do
  viewEvent <- viewMenu
  dyn viewEvent
  blank

viewMenu :: MonadWidget t m => m (Dynamic t (m ()))
viewMenu = el "div" $ do
  heroEvent <- fmap (const (Hero, heroView)) <$> button "Hero view"
  adminEvent <- fmap (const (Admin, adminView)) <$> button "Admin view "
  dynM <- foldDynMaybe (\ new@(symbol, _) (oldSymbol, _) ->
                          if symbol == oldSymbol
                          then Nothing
                          else Just new) (Hero, heroView) (leftmost [heroEvent, adminEvent])
  pure $ fmap snd dynM

data MainView = Hero
              | Admin
              deriving (Show, Eq, Ord, Read)

-- --
-- requestQuests ::  m (Event t (Maybe [Quest]))
-- requestQuests = do

--   let questsEvent =  e
--   pure questsEvent
--   where
--     req =  xhrRequest "GET" "/quest/all" def
--     reqDyn = constDyn req
--     reqEvent = updated reqDyn
