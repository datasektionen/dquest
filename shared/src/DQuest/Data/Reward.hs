{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.Reward where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)
import Data.Int (Int64)

import Data.Time.Clock (UTCTime)

type EXP = Int64
type Level = Int64

data Reward = Muta Int
            | XP EXP
            | Currency Text Int
            | Object Int Text
            | Other Text
            deriving (Show,Read,Eq,Generic)
instance ToJSON Reward
instance FromJSON Reward
