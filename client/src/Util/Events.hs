{-|
Author: Tomas Möre 2017

This should contain any custom and reusable event action
-}

{-# LANGUAGE OverloadedStrings #-}
module Util.Events where

import Reflex.Dom

import GHCJS.Foreign.Callback
import GHCJS.Types

import Data.Text (Text)
import qualified Data.Text as Text

import Control.Monad.IO.Class
import qualified Data.JSString as JSStr
import GHCJS.Marshal.Pure
import GHCJS.Marshal

foreign import javascript unsafe
    "window.addEventListener('hashchange', function(e){$1(e.newURL)});"
    js_addLocationEvent :: Callback (JSVal -> IO ()) -> IO ()

foreign import javascript unsafe
   "$r = window.location;"
   js_getLocation :: IO JSVal

-- |
getLocationDyn :: MonadWidget t m => m (Dynamic t Text)
getLocationDyn = do
  jsLocation <- liftIO js_getLocation
  let location = pFromJSVal jsLocation
  change <- getLocationChangeEvent
  holdDyn location change

-- | Returns an event that triggers when the url changes
getLocationChangeEvent :: MonadWidget t m => m (Event t Text)
getLocationChangeEvent = do
  (event, trigger) <- newTriggerEvent
  liftIO $ setOnLocationChange trigger
  pure event

setOnLocationChange :: (Text -> IO ()) -> IO ()
setOnLocationChange onTagChange = do
  cb <- asyncCallback1 callback
  js_addLocationEvent cb
  where
    callback :: JSVal -> IO ()
    callback e = do
      maybeLoc <- fromJSVal e
      case maybeLoc of
        Just str -> onTagChange str
        Nothing -> pure ()
