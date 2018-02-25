{-# LANGUAGE OverloadedStrings #-}
module DQuest.Widgets.Hero where

import Reflex.Dom

import DQuest.Data.Hero (Hero)
import qualified DQuest.Data.Hero as Hero

import Data.Monoid

import DQuest.Data.Reward
import qualified Data.Text as Text

import Util.Widgets

heroWidget :: MonadWidget t m =>  Hero -> m ()
heroWidget hero =
  divClass "hero-box" $ do
      experienceBarWidget hero
      infoTableWidget hero
      backpackWidget hero
      blank


infoTableWidget :: MonadWidget t m => Hero -> m ()
infoTableWidget hero = el "table" $ el "tbody" $ do
  row $ do
    titleCell "Name: "
    textCell (Hero.alias hero)
  row $ do
    titleCell "Exp: "
    cell $ textShow (Hero.totalEXP hero)
  row $ do
    titleCell "Completed quests: "
    cell $ textShow (0 :: Int)
  blank
  where
    row = el "tr"
    cell = el "td"
    titleCell = cell . h3
    textCell = cell . text
    h3 =  el "h3" . text


experienceBarWidget :: MonadWidget t m => Hero -> m ()
experienceBarWidget hero =
  divClass "hero-info" $ do
      levelIndicatorWidget hero

backpackWidget :: MonadWidget t m => Hero -> m ()
backpackWidget hero = foldWidget "Backpack" True $ do
  mapM_ itemWidget items
  where
    items = filter (\ (_,r) -> r /= XP) $ Hero.backpack hero
    itemWidget :: MonadWidget t m => (Quantity,Reward) -> m ()
    itemWidget (quantity, reward) = divClass "item" $ do
      divClass "quantity" $ text $ (Text.pack . show) quantity
      divClass "item" $ text $ (Text.pack . show) reward

levelIndicatorWidget :: MonadWidget t m => Hero -> m ()
levelIndicatorWidget hero = divClass "lvl-indicator" $ do
  divClass "lvl-text" $ do
    text "LVL"
    el "span" blank -- For a white little line
  divClass "lvl-display" $ do
    text lvl


  where
    lvl = (Text.pack . show) (Hero.level hero)
