{-# LANGUAGE OverloadedStrings #-}
module Servant.DQuestTypes (LoginCookie(..))where

import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text
import qualified Data.List as List
import Servant.API

parseCookieText :: Text -> [(Text,Text)]
parseCookieText  = cookies
  where
      cookies = filter (not.Text.null.snd)   .
                map (stipPair . Text.breakOn "=") .
                Text.splitOn ";"
      stipPair (a,b) = (Text.strip a, Text.stripEnd $ Text.drop 1 b)

newtype LoginCookie = LoginCookie Text deriving (Eq, Show)

instance FromHttpApiData LoginCookie where
  parseUrlPiece = pure . LoginCookie
  parseQueryParam = parseUrlPiece
  parseHeader bsData = maybe (Right (LoginCookie ""))-- "auth cookie not found")
                             (Right . LoginCookie)
                             maybeAuth

    where
      maybeAuth = List.lookup "auth" $ parseCookieText $ Text.decodeLatin1 bsData
