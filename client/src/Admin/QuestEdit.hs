{-|
Author: Tomas Möre 2017

This module defines diffrent widgets for creating and editing Quests.
-}
{-# LANGUAGE RecursiveDo, OverloadedStrings, ScopedTypeVariables  #-}
module Admin.QuestEdit where

import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest
import DQuest.Data.ProtoQuest (ProtoQuest)
import DQuest.Data.ProtoQuest as PQ

import DQuest.Data.Reward

import Display.Quest (questWidget)
import ServerApi

import Reflex.Dom
import Data.Monoid

import Control.Monad.IO.Class

import Data.Text (Text)
import qualified Data.Text as Text

import Data.Map (Map)
import qualified Data.Map as Map

import Control.Lens
import Control.Applicative
import Control.Monad
import Data.Maybe

import Util (dataInput, switchButton)

-- | Quickhand for creating a new quest. When the event quest save
-- hase been triggered it sends a request to the server. If this
-- succeeds the return event fires.
newQuestForm :: MonadWidget t m => m (Event t Quest)
newQuestForm = el "div" $ do
  editEvent <- questEdit PQ.empty
  resultEvent <- createNewQuest editEvent
  pure $ fmapMaybe id resultEvent

-- | Wrapper for editQuest for sending an update request to the
-- server. The returned event fires when the update succeeded.
questEditAndSave :: MonadWidget t m => Quest -> m (Event t Quest)
questEditAndSave quest = do
  saveEvent <- questEdit protoQuest
  updateQuest (fmap (\ p -> (p,dbID)) saveEvent)
  where
    (protoQuest, dbID) = Quest.toProtoQuest quest


-- | Provides a small wrapper for toggelable editing of
-- quests. However it doesn't do any actual updating of the provided
-- quest but the returned event will fire when a proper edit and save
-- click has been made
editQuest :: MonadWidget t m => Quest -> m (Event t Quest)
editQuest quest = el "div" $ do
  editEvent <- switchButton "Edit" "Cancel"
  foldDynMaybe (\ b -> if b
                 then questWidget quest
                 else questEdit (fst $ ))
  widgetHold (questWidget quest)


{-| Quest edit shows the content of a quest and provides the ui
necessary to edit it. When the save button is pressed and the basic
error checks have been done it will fire the returned Event with the
updated ProtoQuest.
-}
questEdit :: MonadWidget t m => ProtoQuest -> m (Event t ProtoQuest)
questEdit proto = el "div" $ do
  nameInput <- textInput def{ _textInputConfig_initialValue = PQ.title proto}
  descriptionInput <- textArea def{ _textAreaConfig_initialValue = PQ.description proto}
  issueInput <- textInput def{ _textInputConfig_initialValue  = fromMaybe "" (PQ.issue proto)}
  let nameDyn = nameInput^.textInput_value
      descriptionDyn = descriptionInput^.textArea_value
      issueValueDyn = issueInput^.textInput_value
      issueDyn = (\ s -> if Text.null s then Nothing else Just s) <$> issueValueDyn
  rewardDyn <- rewardTable (PQ.rewards proto)
  let protoQuestDyn = ProtoQuest <$> nameDyn <*> descriptionDyn <*> issueDyn <*> rewardDyn
  buttonEvent <- button "Save quest"
  pure $ tagPromptlyDyn protoQuestDyn buttonEvent

-- | A widget for editing and creating new rewards. First argument is
-- the default values of the list. Waring to people editing this. It
-- is kinda complicated.
rewardTable :: MonadWidget t m => [(Quantity, Reward)] -> m (Dynamic t [(Quantity, Reward)])
rewardTable defaultRewards = el "div" $ do
  newRewardEvent <- el "div" $ newRewardBox
  rec (currentCreate :: Dynamic t [(Quantity, Reward)], removeEvents :: Event t Reward) <- el "ul" $ do
        let changeEvent = leftmost [Left <$> removeEvents, Right <$> newRewardEvent]
        rewards <- foldDyn (\ e l -> case e of
                               Left r -> filter ((/=r).snd) l
                               Right t -> t:l) defaultRewards changeEvent
        del <- dyn $ (\ l -> leftmost <$> mapM (uncurry rewardListElement) l) <$> rewards
        del' <- holdDyn never del
        pure (rewards, (switchPromptlyDyn del'))
  text "deleted"
  display =<< foldDyn (:) [] removeEvents
  pure $ traceDynWith show $ currentCreate

-- | widgetFor displaying a reward. This includes a delete button. The
-- returned event fires when a specific "reward delete button" is pressed.
rewardListElement :: MonadWidget t m => Quantity -> Reward -> m (Event t Reward)
rewardListElement n r = el "li" $ do
  display (constDyn n)
  text "x"
  rewardDisplay r
  b <- button "remove"
  let deleteEvent = traceEvent "Potato"  $ tagPromptlyDyn (constDyn r) b
  pure deleteEvent

rewardDisplay :: MonadWidget t m => Reward -> m ()
rewardDisplay XP = text "XP"
rewardDisplay (Currency name) = text name >> text "- currency"
rewardDisplay (Item name url) = text name >> text "- item"
rewardDisplay (Other name) = text name >> text "- other"


newRewardBox :: MonadWidget t m => m (Event t (Quantity,Reward))
newRewardBox = el "div" $ do
  choiceDyn <- rewardDropdown
  quantityDyn <- dataInput
  rewardDyn' <- dyn $ fmap rewardDataInput choiceDyn
  rewardDyn <- join <$> holdDyn (constDyn Nothing) rewardDyn'
  let inputDyn = zipDynWith (liftA2 (,)) quantityDyn rewardDyn
  b <- button "Add reward"
  let buttonEvent = tagPromptlyDyn inputDyn b
  pure $ fmapMaybe id buttonEvent

defaultRewards :: Map Reward Text
defaultRewards = Map.fromList [ (XP, "XP")
                              , (Currency "Muta", "Currency")
                              , (Item "" "", "Item")
                              , (Other "", "Something else")
                              ]

rewardDropdown :: MonadWidget t m => m (Dynamic t Reward)
rewardDropdown = _dropdown_value <$> dropdown XP (constDyn defaultRewards) def


rewardDataInput :: MonadWidget t m => Reward -> m (Dynamic t (Maybe Reward))
rewardDataInput XP = pure $ constDyn (Just XP)
rewardDataInput (Currency _) = el "div" $ do
  text "Name of currency: "
  nameDyn <- nonEmptyTextInput
  pure $ fmap Currency <$> nameDyn
rewardDataInput (Item _ _) = el "div" $ do
  text "Name of item:"
  nameDyn <- nonEmptyTextInput
  text "Thumbnail image url"
  imageDyn <- nonEmptyTextInput
  pure $ zipDynWith (\ maybeName maybeUrl -> Item <$> maybeName <*> maybeUrl) nameDyn imageDyn
rewardDataInput (Other _) = el "div" $ do

  text "Describe this other thing: "
  textDyn <- nonEmptyTextInput
  pure $ fmap Other <$> textDyn


nonEmptyTextInput :: MonadWidget t m => m (Dynamic t (Maybe Text))
nonEmptyTextInput = do
  input <- textInput def
  pure $ fmap (\ t -> if Text.null t then Nothing else Just t) (input^.textInput_value)
