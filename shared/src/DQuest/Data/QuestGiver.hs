{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module DQuest.Data.QuestGiver where

import Data.Aeson
import GHC.Generics

import Data.Text

type QuestGiverName = Text

data QuestGiver = QuestGiver
                  { name        :: Text
                  , description :: Text
                  , plsGroup    :: Text
                  } deriving (Show,Read,Eq,Generic)
instance ToJSON QuestGiver
instance FromJSON QuestGiver
