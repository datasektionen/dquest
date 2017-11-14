{-# LANGUAGE OverloadedStrings #-}

module Views where

import qualified DQuest.Data.Dummies as Dummy
import DQuest.Data.Quest (Quest)

import Display
import Admin
import ServerApi

import Reflex.Dom

import qualified Data.Text as Text


heroView :: MonadWidget t m => m ()
heroView = el "div" $ do
  heroWidget Dummy.hero1
  pbe <- getPostBuild
  t <- holdDyn Nothing =<< getAllQuests pbe
  dynText ((Text.pack . show) <$> t)
  el "div" $ dyn (fmap (maybe (text "No content") (mapM_ questWidget)) t)
  blank


adminView :: MonadWidget t m => m ()
adminView = do
  newQuestForm
  blank
