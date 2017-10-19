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


registerToken :: LoginApiKey -> KthToken -> MTVHandler (WithToken String)
registerToken login2ApiKey newToken = do
  mUser <- liftIO $ verifyToken login2ApiKey newToken
  if isJust mUser
    then pure $ addHeader newToken $ addHeader "/" ""
    else pure $ noHeader $ addHeader "/" ""

slideServer :: SlideName -> MTVHandler Slide
slideServer name = do
  slide <- querySlide name
  case slide of
    Nothing -> throwError err404
    Just slide -> pure slide

slidesServer :: MTVHandler SlideMap
slidesServer = querySlides

rotationServer :: RotationName -> MTVHandler Rotation
rotationServer name = do
  rotatation <- queryRotation name
  case rotatation of
    Nothing -> throwError err404
    Just rotation -> pure rotation

rotationsServer ::  MTVHandler RotationMap
rotationsServer = queryRotations

saveCookie mToken continuation  = do
  modify (\ s -> s{requestKthToken = mToken})
  logedInOrRedirect
  continuation

userServer :: ServerT UserAPI MTVHandler
userServer mToken =
         wt (lift $ serveFile "protected/index.html") --(pure "Hello world" :: MTVHandler Text)
    :<|> wt slidesServer
    :<|> wt . slideServer
    :<|> wt rotationsServer
    :<|> wt . rotationServer
  where
    -- | Nasty hack
    wt = (saveCookie mToken)


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

--questModifyServer =

questNewServer protoQuest{..} = do

  where
    newQuest = Quest
      { title = protoTitle
      , description = protoDesciption
      , issue = protoIssue
      , comments = []
      }


insertServer
