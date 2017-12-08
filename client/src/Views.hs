{-# LANGUAGE OverloadedStrings #-}

module Views where

import qualified DQuest.Data.Dummies as Dummy
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest

import Display.Hero
import Display.Quest

import Admin.QuestEdit
import DQuest.ServerApi
import DQuest.Nav
import Reflex.Dom
import qualified Data.Text as Text
import Data.Monoid

import Control.Monad.IO.Class

import Util.Widgets
import Util.Cookie
import Util.Location


mainView :: MonadWidget t m => Location -> m ()
mainView location = do
  divID "content" $ content location
  where
    content :: MonadWidget t m => Location -> m ()
    content (Location [""] _) = heroView
    content (Location ("quests":_) _) = heroView
    content (Location ("admin":_) _) = adminView
    content (Location ("login":loginCode:_) _) = liftIO $ do
      liftIO $ print =<< getLocation
      print =<< getCookie "auth"
      setCookieSimple "auth" loginCode
      setLocation ""
    content _ = do
      heroView --liftIO $ changeLocationHash ""


-- | The main view for the user any information that the normal user
-- should see should start from here
heroView :: MonadWidget t m => m ()
heroView = do
  heroDyn <- getCurrentHero
  display heroDyn
  heroWidget Dummy.hero1
  t <- getAllQuests =<< getPostBuild
  divClass "quest-wrapper" $ do
    texInp <- elAttr "div" ("class" =: "search-area") $ divClass "search-content" $ do
      textInput def{ _textInputConfig_attributes = constDyn ("class" =: "subtle")}
    dyn (fmap  (mapM_ questWidget) t)
  blank

-- | The main view for an admin.
adminView :: MonadWidget t m => m ()
adminView = do
  allQuestsDyn <- getAllQuests =<< getPostBuild
  searchStrDyn <- _textInput_value <$> (textInput def{
                                           _textInputConfig_attributes = constDyn ("class" =: "subtle")
                                           })
  let filteredQuests = zipDynWith (\ qs filterStr ->
                                     filter (\ q -> Text.isInfixOf filterStr (Quest.title q) ||
                                                    Text.isInfixOf filterStr (Quest.description q)
                                            ) qs
                                  ) allQuestsDyn searchStrDyn
  newQuest <- newQuestForm
  dynText $ (\ s -> if s == mempty then "No filter" else "Using filter: " <> s) <$> searchStrDyn
  el "div" $ dyn (fmap  (mapM_ questWidget) filteredQuests)
  blank
