{-| This module exists to extend the standard seravant api since it
doesn't have a simple "ServeFile" function. Note that this also
depends on the Servant.Ext.Types as defined in the "shared" module
-}
{-# LANGUAGE OverloadedStrings, MultiParamTypeClasses #-}
module Servant.Ext (module Types, serveFile) where


import Data.ByteString.Lazy as BL
import System.Directory
import Servant.Ext.Types as Types
import Servant
import Servant.Server.Internal.Handler
import Servant.Server.Internal.ServantErr (err404)

import Control.Monad.Trans
import Control.Monad.Except
import Control.Monad



-- | Given a filepath it will serve the contents of that file as a
-- Blob, Blob is defined in Server.Ext.Types.
serveFile :: FilePath -> Handler Blob
serveFile fp = do
  exists <- liftIO $ doesFileExist fp
  unless exists $ throwError err404
  Blob <$> liftIO (BL.readFile fp)
