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



-- | A Button that switches between two diffrent text values.
switchButton :: MonadWidget t m => Text -> Text -> m (Event t Bool)
switchButton t1 t2 = do
  rec buttonEvent <- switchPromptlyDyn <$> widgetHold button1 (buttonSwitch <$> buttonEvent)
  pure buttonEvent

  where
    button1 = fmap (const True) <$> button t1
    button2 = fmap (const False) <$> button t2
    buttonSwitch True = button2
    buttonSwitch False = button1
