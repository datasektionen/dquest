{-# LANGUAGE OverloadedStrings #-}
module Display.Hero where

import Reflex.Dom
import Control.Monad.IO.Class
import DQuest.Data.Quest (Quest)
import qualified DQuest.Data.Quest as Quest

import DQuest.Data.Hero (Hero)
import qualified DQuest.Data.Hero as Hero

import Data.Monoid

import qualified Data.Text as Text


heroWidget hero =
  divClass "hero-box" $ do
      experienceBarWidget hero

      questInspectWidget hero
      blank



questInspectWidget hero = blank


experienceBarWidget hero =
  divClass "hero-info" $ do
      el "div" $ do
        el "span" $ text "LVL: "
        elAttr "h3" ("class" =: "level-nr cerise") $ text $ (Text.pack . show) (Hero.level hero)
      el "div" $ elAttr "progress" ("class" =: "exp-bar" <> "max" =: "100" <> "value" =: "50" ) blank
      text $ if Text.null $ Hero.alias hero
               then Hero.kthid hero
               else Hero.alias hero
