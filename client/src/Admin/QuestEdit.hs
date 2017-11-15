{-# LANGUAGE RecursiveDo, OverloadedStrings, RankNTypes, ScopedTypeVariables  #-}
module Admin.QuestEdit where

import DQuest.Data.Quest (Quest)

import DQuest.Data.ProtoQuest (ProtoQuest)
import DQuest.Data.ProtoQuest as PQ

import DQuest.Data.Reward

import Display
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

import Util (dataInput)

-- | Quickhand for creating a new quest. When the event quest save
-- hase been triggered it sends a request to the server. If this
-- succeeds the return event fires.
newQuestForm :: MonadWidget t m => m (Event t Quest)
newQuestForm = el "div" $ do
  editEvent <- questEdit PQ.empty
  resultEvent <- createNewQuest createEvent
  pure $ fmapMaybe id resultEvent


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




-- Might be the most overly compicated heap of garbage i've ever written.
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

-- let changeEvent = leftmost [Left <$> removeEvents, Right <$> newRewardEvent]
--             createdRewards = foldDyn (\ change l -> case change of
--                                          Left e -> filter ((/=e) . snd) l
--                                          Right t@(q,r) -> t:l) [] changeEvent
--             displayList = mapM (uncurry rewardListElement)  <$> createdRewards
--         del <- widgetHold (pure never) (dyn displayList)
--         pure (createdRewards, updated del)

rewardListElement :: forall t m . MonadWidget t m =>  Quantity -> Reward -> m (Event t Reward)
rewardListElement n r = el "li" $ do
  display (constDyn n)
  text "x"
  rewardDisplay r
  b <- button "remove"
  let deleteEvent = traceEvent "Potato"  $ tagPromptlyDyn (constDyn r) b
  pure deleteEvent

rewardDisplay :: forall t m . MonadWidget t m => Reward -> m ()
rewardDisplay XP = text "XP"
rewardDisplay (Currency name) = text name >> text "- currenc"
rewardDisplay (Item name url) = text name >> text "- item"
rewardDisplay (Other name) = text name >> text "- other"


newRewardBox :: forall t m . MonadWidget t m => m (Event t (Quantity,Reward))
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

rewardDropdown ::  forall t m . MonadWidget t m => m (Dynamic t Reward)
rewardDropdown = _dropdown_value <$> dropdown XP (constDyn defaultRewards) def


rewardDataInput :: forall t m . MonadWidget t m => Reward -> m (Dynamic t (Maybe Reward))
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


nonEmptyTextInput :: forall t m . MonadWidget t m => m (Dynamic t (Maybe Text))
nonEmptyTextInput = do
  input <- textInput def
  pure $ fmap (\ t -> if Text.null t then Nothing else Just t) (input^.textInput_value)


--rewardDisplay :: Event t (Maybe (Reward,)
