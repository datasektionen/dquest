{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
module Datasektionen.Login.Internal  where

import Datasektionen.Login.Types

import qualified Network.Wai as Wai

import Data.Monoid

import Data.Maybe (fromMaybe)
import Data.Functor
import Data.String
import Servant.Client
import Servant.Utils.Links

import Servant.API
import Data.Proxy

import Control.Exception
import Data.Text (Text)
import Data.String

--import Network.HTTP.Client (newManager, defaultManagerSettings)
import Network.HTTP.Client.TLS (newTlsManager)
import Network.URI (uriToString, URIAuth(..))



-- | Static key value for the KTH token
staticTokenKey :: IsString s => s
staticTokenKey = "KTH_TOKEN"

login2URLWCallback :: IsString s => s
login2URLWCallback = "https://login2.datasektionen.se/login?callback="

loginBaseHost :: IsString s => s
loginBaseHost = fromString "login2.datasektionen.se"
loginBaseUrl = BaseUrl Http loginBaseHost 80 ""

type LoginApi = "login" :> QueryParam "callback" Text :> Verb 'GET 200 '[JSON] NoContent
--type LoginApi = "login" :> QueryParam "callback" URIEncoded :> Verb 'GET 200 '[JSON] NoContent

loginLink :: Text -> Text
loginLink callback = "https://" <> loginBaseHost <> "/" <> toUrlPiece link <> "/"
  where
    proxy = Proxy :: Proxy LoginApi
    link = safeLink proxy proxy (Just  callback)

type VerifyApi = "verify":> Capture "token" (JsonExtention KthToken) :> QueryParam "api_key" LoginApiKey :>  Get '[JSON] User

verifyApi = (Proxy :: Proxy VerifyApi)

verify = client verifyApi

-- https://login2.datasektionen.se/verify/MzwN5lW6NPzVLY5jDJGy9A?format=json&api_key=dquest-server-7f550fe666424f1c90df53d5bddcbe1c

-- api_key=dquest-server-7f550fe666424f1c90df53d5bddcbe1c
verifyToken :: LoginApiKey -> KthToken -> IO (Maybe User)
verifyToken apikey token = do
  manager <- newTlsManager
  res <- runClientM (verify  (JsonExtention token) (Just apikey)) (ClientEnv manager loginBaseUrl)
  case res of
    Left err   -> pure Nothing <$> print err
    Right user -> pure $ Just user
