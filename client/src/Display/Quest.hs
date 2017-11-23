{-# LANGUAGE OverloadedStrings #-}
module Display.Quest where

import Reflex.Dom
import Control.Monad.IO.Class
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest

import DQuest.Data.Hero (Hero)
import qualified DQuest.Data.Hero as Hero

import Data.Monoid

import qualified Data.Text as Text


questWidget :: MonadWidget t m => Quest -> m ()
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
