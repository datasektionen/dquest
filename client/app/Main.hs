{-# LANGUAGE OverloadedStrings #-}
module Main where

import Views
import Reflex.Dom
import Data.Monoid

import DSekt.Methone
import DQuest.Nav


methoneConfig = MethoneConf
                { system_name  = "dquest"
                , color_scheme = "cerice"
                , login_text   = ""
                , login_href   = "#login"
                , links        = [MethoneLink "Hero" "#hero"
                                 ,MethoneLink "Admin" "#admin"]
                }

{-
The main method works much like in normal haskell. You're free to run
any arbitrary IO code in here. But we use it to start the reflex doom environment.
-}
main :: IO ()
main = mainWidgetWithHead htmlHead (methoneWrapper methoneConfig dquestContent)

dquestContent :: MonadWidget t m => m ()
dquestContent = do
  locDyn <- getLocationDyn
  display locDyn
  dyn $ mainView <$> locDyn
  blank

htmlHead :: MonadWidget t m => m ()
htmlHead = do
  elAttr "link" ("href" =: "https://aurora.datasektionen.se/" <> "type" =: "text/css" <> "rel" =: "stylesheet") blank
  elAttr "meta" ("charset" =: "UTF-8") blank

{- |
Simple switch for the different main views. Won't update the same view twice.x
-}
viewMenu :: MonadWidget t m => m (Dynamic t (m ()))
viewMenu = do

  heroEvent <- fmap (const (Hero, heroView)) <$> button "Hero view"
  adminEvent <- fmap (const (Admin, adminView)) <$> button "Admin view "
  dynM <- foldDynMaybe (\ new@(symbol, _) (oldSymbol, _) ->
                          if symbol == oldSymbol
                          then Nothing
                          else Just new) (Hero, heroView) (leftmost [heroEvent, adminEvent])
  pure $ fmap snd dynM

-- | Datatype only used for the @viewMenu function
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
