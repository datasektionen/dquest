{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.Comment where


import Data.Aeson
import GHC.Generics
import Data.Text (Text)
import Datasektionen.Types

import Data.Time.Clock (UTCTime)

data Comment = Comment
  { user :: KthID
  , content :: Text
  , uploaded :: UTCTime
  , history :: [(UTCTime, Text)]
  } deriving (Show,Read,Eq,Generic)

instance ToJSON Comment
instance FromJSON Comment
