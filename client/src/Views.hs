{-# LANGUAGE OverloadedStrings #-}

module Views where

import DQuest.Data.Quest (Quest)

import qualified DQuest.Data.Quest as Quest
import DQuest.Data.Hero (Hero)
import qualified DQuest.Data.Comment as Comment

import DQuest.Widgets.Hero
import DQuest.Widgets.Quest
import DQuest.Widgets.QuestEdit
import DQuest.Widgets.QuestPage
import DQuest.Widgets.Search


import DQuest.Util
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
  heroDyn <- getCurrentHero
  elAttr "div" ("id" =: "content" <> "class" =: "cerise") $ content location heroDyn
  where
    content :: MonadWidget t m => Location -> Dynamic t (Maybe Hero) -> m ()
    content (Location [""] _)  = heroView
    content (Location ("quests":_) _)  = heroView
    content (Location ("quest": questId : []) _) = questView questId
    content (Location ("admin":_) _)   = adminView
    content (Location ("login":loginCode:_) _)  = const $ liftIO $ do
      liftIO $ print =<< getLocation
      print =<< getCookie "auth"
      setCookieSimple "auth" loginCode
      setLocation ""
    content _  = do
      heroView

-- | The main view for the user any information that the normal user
-- should see should start from here
heroView :: MonadWidget t m => Dynamic t (Maybe Hero) -> m ()
heroView heroDyn = do
  dyn $ maybe blank heroWidget <$> heroDyn
 -- heroWidget heroDyn
  quests <- getAllQuests =<< getPostBuild
  divClass "quest-wrapper" $ do
    so <- searchAreaWidget
    let filteredQuests = (filter <$> matchesSearch <$> so) <*> quests
    dyn $ fmap  (mapM_ questWidget) filteredQuests
  blank


-- | The main view for an admin.
adminView :: MonadWidget t m => Dynamic t (Maybe Hero) -> m ()
adminView hDyn = do
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




questView :: MonadWidget t m => Quest.ID -> Dynamic t (Maybe Hero) -> m ()
questView questId heroDyn = do

  dyn $ maybe blank heroWidget <$> heroDyn
  q <- getQuestByID questId
  display q -- remove
  divClass "quest-wrapper" $ do
    dyn $ (\ res -> case res of
                           Nothing -> questViewLoading
                           Just Nothing -> questViewFailed
                           Just (Just quest) -> questViewFull quest heroDyn
          ) <$> q
  blank


questViewLoading :: MonadWidget t m =>  m ()
questViewLoading = do
  text "Loading hero"
questViewFailed :: MonadWidget t m => m ()
questViewFailed = do
  text "Quest not found!"

questViewFull :: MonadWidget t m => Quest -> (Dynamic t (Maybe Hero)) -> m ()
questViewFull quest heroDyn = divClass "quest-full" $ do
    divClass "title" $ el "h1" $ text (Quest.title quest)
    divClass "metadata" $ do
      divClass "created" $ do
        text "Date created:"
        display $ pure $ Quest.uploaded quest
      divClass "author:" $ do
        text "Created by:"
        display $ pure $ Quest.creator quest
      divClass "difficulty" $ do
        text "Difficulty level"
        display $ pure $ Quest.difficulty quest
      case Quest.closed quest of
        Nothing -> blank
        Just closeTime -> divClass "closed" $ do
          text "Time closed"
          display $ pure $ closeTime
    divClass "description" $ text $ Quest.description quest

    divClass "assigned" $ mapM_ kthPic (Quest.assigned quest)
    dyn $ (\ mHero -> case mHero of
                                   Nothing -> blank
                                   Just hero -> do
                                     acceptQuestE <- button "Accept quest!"
                                     acceptQuest $ fmap (const (Quest.id quest)) acceptQuestE
                                     blank
               ) <$> heroDyn
    divClass "comment-area" $ do
      divClass "new" $ do
        blank
      divClass "comments" $ do
        mapM_ commentBox $ Quest.comments quest



   where
     commentBox comment = divClass "comment" $ do
       divClass "header" $ do
         divClass "author" $ text $ Comment.user comment
         divClass "time" $ display $ pure $ Comment.uploaded comment
       divClass "content" $ text $ Comment.content comment
