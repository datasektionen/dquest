{-# LANGUAGE DataKinds, DeriveGeneric, FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module DQuest.Routes where

import Prelude ()
import Prelude.Compat

import Data.Text (Text)
import Data.Time.Clock (UTCTime)

import Servant.API
import Servant.Ext.Types

import Datasektionen.Types
import DQuest.Data

import Data.ByteString (ByteString)
import qualified Data.Text.Encoding as Text

import Servant.DQuestTypes
{-

-}

type QuestLookup =    "open"   :> Get '[JSON] [Quest]
                 :<|> "all"    :> Get '[JSON] [Quest]
                 :<|> "closed" :> Get '[JSON] [Quest]

type QuestKey = Capture "title" Text :> Capture "date" UTCTime
-- type QuestModify = "modify" :> "description" :> QuestKey :> ReqBody '[JSON] Text :> POST '[JSON] Bool

type QuestNew = "new" :> ReqBody '[JSON] ProtoQuest :> Post '[JSON] Quest

type QuestUpdate = "update" :> Capture "dbID" Text :> ReqBody '[JSON] ProtoQuest :> Post '[JSON]  Bool

type AssignToQuest = "assign" :> Capture "dbID" Text :> Header "Cookie" LoginCookie :> Get '[JSON] Bool

type JsonAPI =  ("quest" :> (QuestLookup :<|> QuestNew :<|> QuestUpdate :<|> AssignToQuest))
           :<|> HeroJsonApi

type HeroJsonApi =
  "hero" :> ("identify" :>  Header "Cookie" LoginCookie :> Get '[JSON] (Maybe Hero))

type Index = Get '[HTML] Blob
type PublicDir = Raw


type ServerApi = JsonAPI :<|> Index :<|> PublicDir

-- curl -i -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8080/quest/new
