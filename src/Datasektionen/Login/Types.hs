{-# LANGUAGE DataKinds, DeriveGeneric, FlexibleInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, OverloadedStrings, ScopedTypeVariables, TypeOperators #-}

module Datasektionen.Login.Types where

import Prelude ()
import Prelude.Compat

import Servant

import Safe (headMay, tailMay)

import Data.ByteString (ByteString)

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T

import Data.Aeson
import GHC.Generics

import Data.Maybe
import Data.Monoid

import Control.Monad

type KthID = Text

data User = User
            { first_name  :: Text
            , last_name   :: Text
            , emails      :: Text
            , user        :: Text
            , ugkthid     :: Text
            } deriving (Show,Read,Eq,Generic)

instance ToJSON User
instance FromJSON User

newtype KthToken = KthToken{ unKthToken :: Text}
  deriving (Show, Eq, Read)
kthTokenKey = "KTH_TOKEN"

-- | Enables reading
instance FromHttpApiData KthToken where
  -- | Parse URL path piece.
  parseUrlPiece = Right . KthToken
  -- | Looks through the cookies in the header given,
  parseHeader bs = case lookup kthTokenKey allCookies of
                     Nothing -> Left "Missing"
                     Just token -> Right $ KthToken token
    where
      allCookies =  cookieParser bs
  -- | Parse query param value.
  parseQueryParam =  Right . KthToken

-- | This really isn't a perfect way to descsribe the cookie for
-- headers
instance ToHttpApiData KthToken where
  -- | Convert to URL path piece.
  toUrlPiece = unKthToken

  -- | Convert to HTTP header value.
  -- only gives out the "KTH_TOKEN=..."
  toHeader = T.encodeUtf8 .  (<>";path=/") . mappend (kthTokenKey <> "=") . unKthToken

  -- | Convert to query param value.
  toQueryParam = unKthToken


-- | Dirty hack
newtype JsonExtention a = JsonExtention{ unJsonExtention :: a}

instance FromHttpApiData a => FromHttpApiData (JsonExtention a) where
  parseUrlPiece =  parseUrlPiece . fst . T.breakOn ".json"
  parseQueryParam = parseUrlPiece

instance ToHttpApiData a => ToHttpApiData (JsonExtention a) where
  toUrlPiece = (<>".json") . toUrlPiece . unJsonExtention
  toQueryParam = toUrlPiece

cookieParser :: ByteString -> [(Text, Text)]
cookieParser str = catMaybes $ do
        unparsedField <- T.splitOn ";" (T.decodeUtf8 str)
        let parsedField = T.splitOn "=" unparsedField
        pure $ pure (,) <*> (T.strip <$> headMay parsedField)  <*> (tailMay >=> headMay ) parsedField

newtype LoginApiKey = LoginApiKey{ unLoginApiKey :: Text}

instance ToHttpApiData LoginApiKey where
  toUrlPiece = unLoginApiKey
  toHeader = T.encodeUtf8 . mappend "api_key=" . unLoginApiKey
  toQueryParam = unLoginApiKey
