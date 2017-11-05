{-# LANGUAGE OverloadedStrings #-}
module Test where

import Reflex.Dom
import Control.Monad.IO.Class

-- Simple example on how to make subEvents trigger events on a higher level.
controlText = mainWidget $ do
  (event, trigger) <- newTriggerEvent
  let left = el "div" $ do
        e <- button "Left"
        performEvent_ $ fmap (\ _ -> liftIO $ trigger True) e
        return ()
      right = el "div" $ do
        e <- button "Right"
        performEvent_ $ fmap (\ _ -> liftIO $ trigger False) e
        blank
      displayEvent = fmap (\ e -> if e then right else left) event

  widgetHold left displayEvent
  blank
