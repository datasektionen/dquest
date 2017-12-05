{-|
Author: Tomas Möre 2017
-}
{-# LANGUAGE OverloadedStrings #-}
module Util.Cookie ( getCookieStr
                   , getCookies
                   , getCookie
                   , setCookie
                   , setCookieSimple
                   , removeCookie) where

import Reflex.Dom

import GHCJS.Foreign.Callback
import GHCJS.Types

import Data.Text (Text)
import qualified Data.Text as Text

import GHCJS.Marshal.Pure
import GHCJS.Marshal
import Data.Maybe
import Data.Monoid

import qualified Data.List as List

import Data.Time.Calendar
import Data.Time.Clock
import Data.Time.Format


foreign import javascript unsafe
  "$r = document.cookie"
  js_getCookiesString :: IO JSVal

foreign import javascript unsafe
  "document.cookie = $1"
  js_setCookieString :: JSVal -> IO ()


getCookieStr :: IO Text
getCookieStr = do
  jsCookieStr <- js_getCookiesString
  maybeCookieStr <- fromJSVal jsCookieStr
  return $ fromMaybe "" maybeCookieStr

getCookies :: IO [(Text,Text)]
getCookies = do
  cookieStr <- getCookieStr
  return $ fmap (stripPair . Text.breakOn "=") $ Text.splitOn ";" cookieStr
  where
    stripPair (a,b) = (Text.stripStart a,Text.stripStart  $ Text.drop 1 b)


getCookie :: Text -> IO (Maybe Text)
getCookie name = List.lookup name <$> getCookies

setCookie :: Text -> Text -> Maybe Text -> Maybe UTCTime -> IO ()
setCookie name value mPath mExpires =
  js_setCookieString $ pToJSVal $ name <> "=" <> value <> ";" <> expires <> path
  where
    timeFormat = ("expires="<>) . Text.pack . formatTime defaultTimeLocale "%a, %d %h %Y %T GMT"
    expires = maybe "" ((<>"; ") . timeFormat)  mExpires
    path = maybe "" (\p -> "path=" <> p <> "; ") mPath

removeCookie :: Text -> IO ()
removeCookie name =
  setCookie name "" Nothing (Just $ UTCTime (ModifiedJulianDay 0) 0)


setCookieSimple :: Text -> Text -> IO ()
setCookieSimple name value =
  setCookie name value (Just "/") (Just fiveHuderedYears)
  where
    fiveHuderedYears = UTCTime (ModifiedJulianDay (365 * 500)) 0
