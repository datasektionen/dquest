{-|
Author: Tomas Möre 2017


Stupid name of module. Put somewhere else, later...
-}
{-# LANGUAGE OverloadedStrings #-}
module DQuest.Identify where


import DQuest.Data.Hero (Hero)
import qualified Datasektionen.Login as Login

import qualified DQuest.Database as DB
import Data.Text (Text)

loginApiKey =  Login.LoginApiKey "dquest-server-7f550fe666424f1c90df53d5bddcbe1c"

identify :: Text -> IO (Maybe Hero)
identify token = do
  mUser <-  Login.verifyToken loginApiKey (Login.KthToken token)
  maybe (pure Nothing) ((fmap Just) . DB.findOrInsertHero . Login.user) mUser
