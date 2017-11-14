{-# LANGUAGE OverloadedStrings #-}

module ServerApi where

import DQuest.Data.Quest (Quest)
import Reflex.Dom
import DQuest.Data.ProtoQuest

getAllQuests :: MonadWidget t m => Event t a ->  m (Event t (Maybe [Quest]))
getAllQuests trigger =
  getAndDecode (const "/quest/all" <$> trigger)


createNewQuest :: MonadWidget t m => Event t ProtoQuest -> m (Event t (Maybe Quest))
createNewQuest createEvent =
  fmap decodeXhrResponse <$> performRequestAsync req
  where
    req = postJson "/quest/new" <$> createEvent
