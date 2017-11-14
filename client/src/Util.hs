{-# LANGUAGE RecursiveDo, OverloadedStrings, RankNTypes  #-}
module Util where


import Reflex.Dom
import Text.Read (readMaybe)

import Data.Text (Text)
import qualified Data.Text as Text

import Control.Lens


dataInput :: forall t m a . (MonadWidget t m, Read a) => m (Dynamic t (Maybe a))
dataInput = do
  inp <- textInput def
  pure $ fmap (readMaybe . Text.unpack) (inp^.textInput_value)
