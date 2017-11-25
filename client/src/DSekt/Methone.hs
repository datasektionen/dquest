{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module Methone (MethoneConf(..), MethoneLink(..), methoneWrapper, ) where


import Reflex.Dom
import Data.Monoid

import GHC.Generics
import GHCJS.Types
import GHCJS.Marshal

import Data.Aeson

import Data.Default
import Data.Text (Text)

import Control.Monad.IO.Class


data MethoneConf = MethoneConf
                   { system_name  :: Text
                   , color_scheme :: Text
                   , login_text   :: Text
                   , login_href   :: Text
                   , links        :: [MethoneLink]
                   } deriving (Show, Read, Eq, Generic)
instance ToJSON MethoneConf
instance FromJSON MethoneConf
instance ToJSVal MethoneConf where
  toJSVal = toJSVal_aeson
instance Default MethoneConf where
  def = MethoneConf "" "" "" "" []

data MethoneLink = MethoneLink
            { str  :: Text
            , href :: Text
            } deriving (Show, Read, Eq, Generic)
instance ToJSON MethoneLink
instance FromJSON MethoneLink
instance ToJSVal MethoneLink where
  toJSVal = toJSVal_aeson

methoneLinkToJSVal :: MethoneLink -> IO JSVal
methoneLinkToJSVal = toJSVal_aeson

foreign import javascript safe
   "window.methone_conf = $1;"
   js_setMethoneConfig :: JSVal -> IO ()

setMethoneConfig :: MethoneConf -> IO ()
setMethoneConfig conf = toJSVal conf >>= js_setMethoneConfig


methoneUrl :: Text
methoneUrl = "//methone.datasektionen.se/bar.js"

methoneWrapper :: MonadWidget t m => MethoneConf -> m a -> m a
methoneWrapper config content = do
  elAttr "div" ("id" =:"methone-container-replace") (el "nav" blank)
  liftIO $ setMethoneConfig config
  res <- content
  elAttr "script" ("src" =: methoneUrl) blank
  pure res
