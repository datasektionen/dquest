{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.Reward where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)


data Reward = Muta Int
            | XP Int
            | Currency Text Int
            | Object Int Text
            | Other Text
            deriving (Show,Read,Eq,Generic)
instance ToJSON Reward
instance FromJSON Reward
