{-# LANGUAGE OverloadedStrings #-}
module Display where

import Reflex.Dom
import Control.Monad.IO.Class
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest

import DQuest.Data.Hero (Hero)
import qualified DQuest.Data.Hero as Hero

import Data.Monoid

import qualified Data.Text as Text


questWidget quest =
  el "div" $ do
      el "div" $ text (Quest.title quest)
      el "div" $ text (Quest.description quest)
      el "div" $ mapM_ pic (Quest.assigned quest)
      _ <- button "Assign yourself!"
      blank
  where
    pic kthID = elAttr "img" ("src" =: dummyImage <> "class" =: "") blank
    dummyImage = "http://i.kinja-img.com/gawker-media/image/upload/s--uJCJoTTM--/19cn7p7ve71yxjpg.jpg"



heroWidget hero =
  el "div" $ do
      el "div" $ do
        text $ if Text.null $ Hero.alias hero
               then Hero.kthid hero
               else Hero.alias hero
      experienceBarWidget hero
      questInspectWidget hero
      blank


questInspectWidget hero = blank


experienceBarWidget hero =
  el "div" $ do
      text $ "Level: " <> (Text.pack . show) (Hero.level hero)
      elAttr "progress" ("class" =: "expBar" <> "max" =: "100" <> "value" =: "50" ) blank
