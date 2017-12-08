{-|
Author: Tomas Möre 2017

This should contain any custom and reusable event action
-}

{-# LANGUAGE OverloadedStrings #-}
module Util.Location where

import Reflex.Dom

import GHCJS.Foreign.Callback
import GHCJS.Types

import Data.Text (Text)
import qualified Data.Text as Text

import Control.Monad.IO.Class
import qualified Data.JSString as JSStr
import GHCJS.Marshal.Pure
import GHCJS.Marshal

import Data.Monoid

foreign import javascript unsafe
   "window.addEventListener('hashchange', function(){$1(window.location.hash)});"
   js_addLocationEvent :: Callback (JSVal -> IO ()) -> IO ()

foreign import javascript unsafe
   "$r = window.location;"
   js_getLocation :: IO JSVal

foreign import javascript unsafe
   "$r = window.location.hash;"
   js_getLocationHash :: IO JSVal

foreign import javascript unsafe
   "window.location = $1;"
   js_setWindowLocation :: JSVal -> IO ()

foreign import javascript unsafe
   "window.location.hash = $1;"
   js_setWindowLocationHash :: JSVal -> IO ()


getLocation :: IO Text
getLocation = pFromJSVal <$> js_getLocation

getLocationHash :: IO Text
getLocationHash = do
  pFromJSVal <$> js_getLocationHash

-- |
getLocationHashDyn :: MonadWidget t m => m (Dynamic t Text)
getLocationHashDyn = do
  hash <- liftIO getLocationHash
  change <- getLocationHashChangeEvent
  holdDyn hash change

-- | Returns an event that triggers when the url changes
getLocationHashChangeEvent :: MonadWidget t m => m (Event t Text)
getLocationHashChangeEvent = do
  (event, trigger) <- newTriggerEvent
  liftIO $ setOnLocationHashChange trigger
  pure event

setOnLocationHashChange :: (Text -> IO ()) -> IO ()
setOnLocationHashChange onTagChange = do
  cb <- asyncCallback1 callback
  js_addLocationEvent cb
  where
    callback :: JSVal -> IO ()
    callback e = do
      maybeLoc <- fromJSVal e
      case maybeLoc of
        Just str -> onTagChange str
        Nothing -> pure ()

setLocation :: Text -> IO ()
setLocation = js_setWindowLocation . pToJSVal

changeLocationHash :: Text -> IO ()
changeLocationHash newHash = do
  location <- getLocation
  let urlPart = Text.takeWhile (/='#') location
  setLocation $ urlPart <> "#" <> newHash
