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
                , login_text   = "Identify thyself!"
                , login_href   = "http://login2.datasektionen.se/login?callback=http%3A%2F%2Flocalhost.datasektionen.se%3A8080%2F%23login%2F"
                , links        = [MethoneLink "Quest board"    "#quests"
                                 ,MethoneLink "Hall of heroes" "#hall-of-heroes"
                                 ,MethoneLink "Store"          "#store"
                                 ,MethoneLink "Admin"          "#admin"]
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
  dyn $ mainView <$> locDyn
  blank

htmlHead :: MonadWidget t m => m ()
htmlHead = do
  css "https://aurora.datasektionen.se/"
  css "/style.css"
  elAttr "meta" ("charset" =: "UTF-8") blank

  where
    css link = elAttr "link" ("href" =: link <>
                              "type" =: "text/css" <>
                              "rel" =: "stylesheet") blank
