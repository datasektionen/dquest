{-# LANGUAGE OverloadedStrings #-}

module ServerApi where

import DQuest.Data.Quest (Quest)
import Reflex.Dom
import DQuest.Data.ProtoQuest

import Data.Text (Text)
import qualified Data.Text as T

import Data.Monoid
import Data.Maybe

import Data.Aeson (ToJSON, FromJSON)


getAllQuests :: MonadWidget t m => Event t a ->  m (Event t (Maybe [Quest]))
getAllQuests trigger =
  getAndDecode (const "/quest/all" <$> trigger)


createNewQuest :: MonadWidget t m => Event t ProtoQuest -> m (Event t (Maybe Quest))
createNewQuest createEvent =
  genericJsonPost createEvent (const "/quest/new") id

updateQuest :: MonadWidget t m => Event t (ProtoQuest, Text) -> m (Event t Bool)
updateQuest trigger =
  fmap (fromMaybe False) <$> genericJsonPost trigger (("/quest/update/" <>) . snd) fst

-- | Function for genericly doing most jsonPosts
genericJsonPost :: (MonadWidget t m, ToJSON c, FromJSON b) => Event t a -> (a -> Text) -> (a -> c) -> m (Event t (Maybe b))
genericJsonPost trigger toUrl toData =
  fmap decodeXhrResponse <$> performRequestAsync req
  where
    req = toReq <$> trigger
    toReq a = postJson (toUrl a) (toData a)
