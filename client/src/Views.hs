{-# LANGUAGE OverloadedStrings #-}

module Views where

import qualified DQuest.Data.Dummies as Dummy
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest

import Display.Hero
import Display.Quest
import Admin.QuestEdit
import ServerApi
import Reflex.Dom
import qualified Data.Text as Text
import Data.Monoid

-- | The main view for the user any information that the normal user should see should start from here
heroView :: MonadWidget t m => m ()
heroView = el "div" $ do
  heroWidget Dummy.hero1
  pbe <- getPostBuild
  t <- getAllQuests pbe
  dynText ((Text.pack . show) <$> t)
  el "div" $ dyn (fmap  (mapM_ questWidget) t)
  blank

-- | The main view for an admin.
adminView :: MonadWidget t m => m ()
adminView = do
  allQuestsDyn <- getAllQuests =<< getPostBuild
  searchStrDyn <- _textInput_value <$> (textInput def)
  let filteredQuests = zipDynWith (\ qs filterStr ->
                                     filter (\ q -> Text.isInfixOf filterStr (Quest.title q) ||
                                                    Text.isInfixOf filterStr (Quest.description q)
                                            ) qs
                                  ) allQuestsDyn searchStrDyn
  newQuest <- newQuestForm
  dynText $ (\ s -> if s == mempty then "No filter" else "Using filter: " <> s) <$> searchStrDyn
  el "div" $ dyn (fmap  (mapM_ questWidget) filteredQuests)
  blank
