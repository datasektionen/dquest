{-| This module exists because of missing standard html capabilites in
Servants main module
-}
{-# LANGUAGE OverloadedStrings, MultiParamTypeClasses #-}
module Servant.Ext where


import Network.HTTP.Media ((//))
import Data.ByteString.Lazy as BL
import System.Directory
import Servant

import Control.Monad.Trans
import Control.Monad

data HTML


instance Accept HTML where
  contentType _ = "text" // "html"

newtype Blob = Blob BL.ByteString

serveFile :: FilePath -> Handler Blob
serveFile fp = do
  exists <- liftIO $ doesFileExist fp
  unless exists $ throwError err404
  Blob <$> liftIO (BL.readFile fp)

instance MimeRender HTML Blob where
  mimeRender _ (Blob bs) = bs

instance MimeUnrender HTML Blob where
  mimeUnrender _ = Right . Blob
