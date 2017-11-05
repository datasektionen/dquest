{-# LANGUAGE OverloadedStrings #-}

module DQuest.Data.Dummies where


import DQuest.Data.Quest (Quest(Quest))
import qualified DQuest.Data.Quest as Quest

import DQuest.Data.Hero (Hero)
import qualified DQuest.Data.Hero as Hero

import DQuest.Data.Reward

import Data.Time.Clock
import Data.Time.Calendar

dayZero = (UTCTime (ModifiedJulianDay 0) 0)

hero1 :: Hero
hero1 = Hero.Hero "tmore" "tmore the great" dayZero [XP 1000]

hero2 :: Hero
hero2 = Hero.Hero "janiuk" "djul" dayZero [XP 20]

hero3 :: Hero
hero3 = Hero.Hero "pernyb" "Ze pär" dayZero [XP 0]

heroes :: [Hero]
heroes = [hero1, hero2, hero3]

quest1 = Quest
  { Quest.title = "Testquest1"
  , Quest.description = "Something awesome"
  , Quest.issue = Nothing
  , Quest.assigned = [Hero.kthid hero3]
  , Quest.uploaded = dayZero
  , Quest.closed = Nothing
  }

quest2 = Quest
  { Quest.title = "Test quest 2"
  , Quest.description = "Something else awesome"
  , Quest.issue = Nothing
  , Quest.assigned = [Hero.kthid hero1, Hero.kthid hero2]
  , Quest.uploaded = dayZero
  , Quest.closed = Nothing
  }

quest3 = Quest
  { Quest.title = "Test quest 3"
  , Quest.description = "Something else awesome"
  , Quest.issue = Nothing
  , Quest.assigned = []
  , Quest.uploaded = dayZero
  , Quest.closed = Nothing
  }

quest4 = Quest
  { Quest.title = "Test quest 4"
  , Quest.description = "Something else awesome"
  , Quest.issue = Nothing
  , Quest.assigned = []
  , Quest.uploaded = dayZero
  , Quest.closed = Just (dayZero, [Hero.kthid hero1])
  }

quests = [quest1, quest2, quest3, quest4]
