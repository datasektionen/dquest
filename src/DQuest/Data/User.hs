{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module DQuest.Data.User where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

import Data.Time.Clock (UTCTime)

import Datasektionen.Login (KthID)
import DQuest.Data.Reward

type Username = Text
type ID = KthID

data User = User
  { kthid :: KthID
  , alias :: Username
  , lastVisit :: UTCTime
  , backpack  :: [Reward]
  } deriving (Show,Read,Eq,Generic)
instance ToJSON User
instance FromJSON User
