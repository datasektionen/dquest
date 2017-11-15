{-# LANGUAGE OverloadedStrings #-}
module Main where

import Views
import Reflex.Dom

{-
The main method works much like in normal haskell. You're free to run
any arbitrary IO code in here. But we use it to start the reflex doom environment.
-}
main :: IO ()
main = mainWidget $ do
  viewEvent <- viewMenu
  dyn viewEvent
  blank

{- |
Simple switch for the different main views. Won't update the same view twice.x
-}
viewMenu :: MonadWidget t m => m (Dynamic t (m ()))
viewMenu = el "div" $ do
  heroEvent <- fmap (const (Hero, heroView)) <$> button "Hero view"
  adminEvent <- fmap (const (Admin, adminView)) <$> button "Admin view "
  dynM <- foldDynMaybe (\ new@(symbol, _) (oldSymbol, _) ->
                          if symbol == oldSymbol
                          then Nothing
                          else Just new) (Hero, heroView) (leftmost [heroEvent, adminEvent])
  pure $ fmap snd dynM

-- | Datatype only used for the @viewMenu function
data MainView = Hero
              | Admin
              deriving (Show, Eq, Ord, Read)

-- --
-- requestQuests ::  m (Event t (Maybe [Quest]))
-- requestQuests = do

--   let questsEvent =  e
--   pure questsEvent
--   where
--     req =  xhrRequest "GET" "/quest/all" def
--     reqDyn = constDyn req
--     reqEvent = updated reqDyn
