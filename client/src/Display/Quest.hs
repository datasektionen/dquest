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
  divClass "quest-box" $ do
      divClass "title" $ el "h2" $ text (Quest.title quest)
      divClass "description" $ text (Quest.description quest)
      divClass "suscribed" $ mapM_ pic (Quest.assigned quest)
      _ <- button "Assign yourself!"
      blank
  where
    imgURL kthID = "http://zfinger.sips.datasektionen.se/user/" <> kthID <>  "/image"
    pic kthID = elAttr "img" ("src" =: imgURL kthID <> "class" =: "profile-pic") blank
