{-|
Author: Tomas Möre 2017
-}
{-#LANGUAGE OverloadedStrings #-}
module DQuest.Database.TableNames where

import Data.String

bountyTable :: IsString s => s
bountyTable = "quests"

userTable :: IsString s => s
userTable = "heroes"
