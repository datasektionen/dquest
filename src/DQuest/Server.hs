{-# LANGUAGE DataKinds, FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RecordWildCards #-}

module DQuest.Server where

import Prelude ()
import Prelude.Compat

import Control.Monad.Except
import Data.Maybe
import qualified Data.ByteString as BS
import Network.Wai.Handler.Warp
import Servant
import Servant.Ext
import Datasektionen.Login

import DQuest.Data
import DQuest.Routes

import qualified DQuest.Database as DB

dquestWebApp :: Application
dquestWebApp = serve proxy dquestServer
  where
    proxy =  Proxy :: Proxy ServerApi


dquestServer = jsonServer
           :<|> serveFile "webdata/index.html"
           :<|> serveDirectoryWebApp "webdata"


jsonServer = questServer :<|>

questServer =  questLookupServer
          :<|> questNewServer

questLookupServer =  liftIO DB.activeQuests
                :<|> liftIO DB.closedQuests
                :<|> liftIO DB.allQuests

questNewServer protoQuest{..} = do
  error "Not implemented"
  where
    newQuest = Quest
      { title = protoTitle
      , description = protoDesciption
      , issue = protoIssue
      , comments = []
      }
