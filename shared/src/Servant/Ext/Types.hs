{-| This module exists because of missing standard html capabilites in
Servants main module
-}
{-# LANGUAGE OverloadedStrings, MultiParamTypeClasses #-}
module Servant.Ext.Types where



import Network.HTTP.Media ((//))
import Data.ByteString.Lazy as BL
import Servant.API

data HTML


instance Accept HTML where
  contentType _ = "text" // "html"

newtype Blob = Blob BL.ByteString


instance MimeRender HTML Blob where
  mimeRender _ (Blob bs) = bs

instance MimeUnrender HTML Blob where
  mimeUnrender _ = Right . Blob
