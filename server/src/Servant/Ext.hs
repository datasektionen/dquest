{-| This module exists because of missing standard html capabilites in
Servants main module
-}
{-# LANGUAGE OverloadedStrings, MultiParamTypeClasses #-}
module Servant.Ext (module Types, serveFile) where


import Network.HTTP.Media ((//))
import Data.ByteString.Lazy as BL
import System.Directory
import Servant.Ext.Types as Types
import Servant.Server.Internal.Handler
import Servant.Server.Internal.ServantErr (err404)

import Control.Monad.Trans
import Control.Monad.Except
import Control.Monad


serveFile :: FilePath -> Handler Blob
serveFile fp = do
  exists <- liftIO $ doesFileExist fp
  unless exists $ throwError err404
  Blob <$> liftIO (BL.readFile fp)
