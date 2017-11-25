{-|
Author: Tomas Möre 2017

Should contain code for navigating the site
-}


{-# LANGUAGE OverloadedStrings #-}
module DQuest.Nav where

import Data.Text (Text)
import qualified Data.Text as Text

import Data.Map (Map)
import qualified Data.Map as Map

import Reflex.Dom

import qualified Util.Events as UE
import Data.Default

-- | The location represent how dquest handles the location
data Location = Location
                { path :: [Text]
                , query :: Map Text Text
                } deriving (Show, Read, Eq)

instance Default Location where
  def = Location mempty mempty


--
parseLocation :: Text -> Location
parseLocation t =
  let fragment = fragmentStart t
      (pathStr, rest) = Text.span (not . (=='?')) fragment
      query = if rest == ""
              then mempty
              else Map.fromList $ parseQuery  $ Text.drop 1 rest
  in Location (parsePath pathStr) query
  where
    fragmentStart =
      Text.drop 1 . Text.dropWhile (not . (=='#'))
    parsePath  = dropWhile Text.null . Text.splitOn "/"
    listToPair (a:b:_) = (a,b)
    listToPair (a:[])  = (a, "")
    listToPaur _ = ("","")
    parseQuery = fmap listToPair . filter (not.null) . fmap (Text.splitOn "=") . Text.splitOn "&"

getLocationDyn :: MonadWidget t m  => m (Dynamic t Location)
getLocationDyn = fmap parseLocation <$> UE.getLocationDyn
