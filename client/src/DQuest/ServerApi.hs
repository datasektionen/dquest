{-# LANGUAGE OverloadedStrings #-}

module DQuest.ServerApi where

import DQuest.Data.Quest (Quest)
import Reflex.Dom
import DQuest.Data.ProtoQuest

import Data.Text (Text)
import qualified Data.Text as T

import Data.Monoid
import Data.Maybe

import Data.Aeson (ToJSON, FromJSON)

import Util.Cookie

import DQuest.Data.Hero(Hero)

import Control.Monad.IO.Class

getAllQuests :: MonadWidget t m => Event t a ->  m (Dynamic t [Quest])
getAllQuests trigger = do
  resp <- getAndDecode (const "/quest/all" <$> trigger)
  holdDyn [] $ fromMaybe [] <$> resp


createNewQuest :: MonadWidget t m => Event t ProtoQuest -> m (Event t (Maybe Quest))
createNewQuest createEvent =
  genericJsonPost createEvent (const "/quest/new") id

updateQuest :: MonadWidget t m => Event t (ProtoQuest, Text) -> m (Event t Bool)
updateQuest trigger = do
  resultEvent <- genericJsonPost trigger (("/quest/update/" <>) . snd) fst
  pure $ fromMaybe False <$> resultEvent

-- | Function for genericly doing most json post request
genericJsonPost :: (MonadWidget t m, ToJSON c, FromJSON b) => Event t a -> (a -> Text) -> (a -> c) -> m (Event t (Maybe b))
genericJsonPost trigger toUrl toData =
  fmap decodeXhrResponse <$> performRequestAsync req
  where
    req = toReq <$> trigger
    toReq a = postJson (toUrl a) (toData a)



-- | Retrieves the user if it can. Defaults to Nothing.
getCurrentHero :: MonadWidget t m => m (Dynamic t (Maybe Hero))
getCurrentHero = do
  mAuthCookie <- liftIO $ getCookie "auth"
  case mAuthCookie of
    Nothing -> pure (constDyn Nothing)
    Just "" -> pure (constDyn Nothing)
    Just authCode -> do
      pbe <- getPostBuild
      resp <- getAndDecode (const "/hero/identify" <$> pbe)
      holdDyn Nothing resp
