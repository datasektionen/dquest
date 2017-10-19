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
import Servant
import Servant.Ext

import Datasektionen.Login
import DQuest.Data

import Data.ByteString (ByteString)

{-

-}

type QuestsQuery = GET '[JSON] [Quest]

type QuestLookup =  ("open" :<|> "closed" :<|> "all") :> QuestsResponse

type QuestKey = Capture "title" Text :> Capture "date" UTCTime
-- type QuestModify = "modify" :> "description" :> QuestKey :> ReqBody '[JSON] Text :> POST '[JSON] Bool

type QuestNew = "new" :>  ReqBody '[JSON] ProtoQuest :> Post '[JSON] Quest

type JsonAPI = "quest" (:>  QuestLookup
                       :<|> QuestNew
                         )

type Index =  Raw
type PublicDir = "public" :> GET '[HTML] Blob

type ServerApi = JsonAPI :<|> Index :<|> PublicDir
