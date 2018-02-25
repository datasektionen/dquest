{-# LANGUAGE OverloadedStrings #-}
module DQuest.Widgets.QuestPage  (questPageWidget) where

import Reflex.Dom
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest


import Data.Monoid

import DQuest.ServerApi (acceptQuest)

import DQuest.Data.Difficulty (Difficulty)
import qualified DQuest.Data.Difficulty as Difficulty

import DQuest.Data.Reward

import DQuest.Data.Comment (Comment)
import qualified DQuest.Data.Comment as Comment
import qualified Data.Text as Text

questPageWidget :: MonadWidget t m => Quest -> m ()
questPageWidget quest = divClass "quest-page" $ do
  el "h1" $ text $ Quest.title quest
  divClass "description" $ text $ Quest.description quest
  rewardListWidget $ Quest.rewards quest
  commentsWidget $ Quest.comments quest


rewardListWidget :: MonadWidget t m => BackPack -> m ()
rewardListWidget rewards =
  mapM_ (text . Text.pack . show) rewards


commentsWidget :: MonadWidget t m => [Comment] -> m ()
commentsWidget comments = divClass "commentArea" $ do
  mapM_ commentWidget comments

commentWidget :: MonadWidget t m => Comment -> m ()
commentWidget comment = divClass "comment" $ do
  text $ Comment.content comment
