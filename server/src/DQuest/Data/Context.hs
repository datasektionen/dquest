{-| This is really just here to avoid some potential import loops
|-}

module DQuest.Data.Context where


import DQuest.State.Internal (MetaTvDB)

import Data.Text (Text)
import Datasektionen.Login(LoginApiKey)


-- | This serves as the context in witch the program runns its
-- computations, probably should only be created once at startup
-- Use environment variables to tweak

data AppContext  = AppContext
                   { dsekLogin2APIKey :: LoginApiKey
                   , dbPath           :: String
                   , webPort          :: Int
                   }
