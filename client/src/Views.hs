{-# LANGUAGE OverloadedStrings #-}

module Views where

import qualified DQuest.Data.Dummies as Dummy
import DQuest.Data.Quest (Quest)


import Display.Hero
import Display.Quest
import Admin.View

import ServerApi

import Reflex.Dom

import qualified Data.Text as Text

-- | The main view for the user any information that the normal user should see should start from here
heroView :: MonadWidget t m => m ()
heroView = el "div" $ do
  heroWidget Dummy.hero1
  pbe <- getPostBuild
  t <- holdDyn Nothing =<< getAllQuests pbe
  dynText ((Text.pack . show) <$> t)
  el "div" $ dyn (fmap (maybe (text "No content") (mapM_ questWidget)) t)
  blank

-- | The main view for an admin.
adminView :: MonadWidget t m => m ()
adminView = do
  newQuestForm
  blank
