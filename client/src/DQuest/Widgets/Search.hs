{-# LANGUAGE OverloadedStrings #-}
module DQuest.Widgets.Search where

import Reflex.Dom
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest

import Data.Text (Text)

import qualified Data.Text as Text

import Data.Monoid

import DQuest.ServerApi (acceptQuest)


data SearchOptions = SearchOptions
                     { searchString :: Text
                     , excludedQuestGivers :: [Text]
                     }

matchesSearch :: SearchOptions -> Quest -> Bool
matchesSearch so q = stringPred (Quest.title q) ||
                stringPred (Quest.description q)

  where
    stringPred = Text.isInfixOf (searchString so)

searchAreaWidget :: MonadWidget t m => m (Dynamic t SearchOptions)
searchAreaWidget = wrapper $ background $ do
  sStr <- _textInput_value <$> textInputBar
  pure $ SearchOptions <$> sStr <*> pure []

    where
      wrapper =  elAttr "div" ("class" =: "search-area")
      background =  divClass "search-content"
      textInputBar = textInput def{
        _textInputConfig_attributes = constDyn ("class" =: "ds-secondary-input" <>
                                                "placeholder" =: "Search...")
        }
