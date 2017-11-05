module Main where

import qualified DQuest.Data.Dummies as Dummy

import Display

import Reflex.Dom


main :: IO ()
main = mainWidget $ do
  heroWidget Dummy.hero1
  el "div" $ mapM_ questWidget Dummy.quests
