{-| Author: Tomas Möre 2017

This module serves as the core for the server application.  All
functions that serves some part of the api should be defined here (At
least as wrappers for other function.

Remember that this uses the Sevant API system. If you do now know what
this is. Read the docs!
-}

{-# LANGUAGE DataKinds, FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RecordWildCards #-}

module DQuest.Server (dQuestWebApp, serveOn) where

import Prelude ()
import Prelude.Compat

import Control.Monad.Except
import Servant
import Servant.Ext

import DQuest.Routes
import qualified DQuest.Data.Quest as Quest

import qualified DQuest.Database as DB

import qualified DQuest.Data.Dummies as Dummy

import Network.Wai.Handler.Warp

serveOn :: Port -> IO ()
serveOn port = run port dQuestWebApp

-- | Serves the server
dQuestWebApp :: Application
dQuestWebApp = serve proxy dQuestServer
  where
    proxy =  Proxy :: Proxy ServerApi


dQuestServer = jsonServer
           :<|> serveFile "webdata/index.html"
           :<|> serveDirectoryWebApp "webdata/"


jsonServer = questServer

questServer =  qQuestLookupServer
          :<|> questNewServer

qQuestLookupServer =
   liftIO DB.activeQuests :<|> liftIO DB.allQuests :<|>  liftIO DB.closedQuests


-- questLookupServer =  liftIO DB.activeQuests
--                 :<|> liftIO DB.closedQuests
--                 :<|> liftIO DB.allQuests

questNewServer protoQuest = do
  liftIO $ print protoQuest
  error "Not implemented"
  where
    newQuest = Quest.fromProtoQuest protoQuest
