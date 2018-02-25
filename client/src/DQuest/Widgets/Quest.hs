{-# LANGUAGE OverloadedStrings #-}
module DQuest.Widgets.Quest  (questWidget) where

import Reflex.Dom
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest


import Data.Monoid

import DQuest.ServerApi (acceptQuest)
import DQuest.Util

import DQuest.Data.Difficulty (Difficulty)
import qualified DQuest.Data.Difficulty as Difficulty

questWidget :: MonadWidget t m => Quest -> m ()
questWidget quest =
  divClass "quest-box" $ do
      divClass "title" $ elAttr "a" ("href" =: ("#quest/" <> Quest.id quest))$
        el "h2" $ text (Quest.title quest)
      divClass "difficulty" (difficultyWithColor $ Quest.difficulty quest)
      divClass "description" $ text (Quest.description quest)
      divClass "assigned" $ mapM_ kthPic (Quest.assigned quest)
      acceptQuestEvent <- button "Accept quest!"
      acceptQuest $ fmap (const (Quest.id quest)) acceptQuestEvent
      blank


difficultyWithColor :: MonadWidget t m => Difficulty -> m ()
difficultyWithColor dif = elAttr "span" ("style" =: style) (text $ Difficulty.simpleTextRep dif)
  where
    style = ("color: " <> Difficulty.standardHexColor dif)
