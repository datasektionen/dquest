{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.Reward where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)
import Data.Int (Int64)

import Data.Time.Clock (UTCTime)

type Quantity = Int64
type EXP = Int64
type Level = Int64

data Reward = XP
            | Currency Text
            | Item Text Text
            | Other Text
            deriving (Show,Read,Eq,Generic, Ord)
instance ToJSON Reward
instance FromJSON Reward
