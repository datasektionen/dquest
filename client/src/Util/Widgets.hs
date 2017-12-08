{-|
Author: Tomas Möre

This module should contain all reusable widgets not strictly connected to anything speific on the site. If you're developing on the client side try to abstract common patterns here!

-}

{-# LANGUAGE OverloadedStrings, RecursiveDo #-}
module Util.Widgets where

import Reflex.Dom
import Text.Read (readMaybe)

import Data.Text (Text)
import qualified Data.Text as Text

import Control.Lens
import Data.Monoid


dataInput :: (MonadWidget t m, Read a) => m (Dynamic t (Maybe a))
dataInput = do
  inp <- textInput def
  pure $ fmap (readMaybe . Text.unpack) (inp^.textInput_value)

-- | Simple default textInput with default value
textInputWithValue :: MonadWidget t m => Text -> m (TextInput t)
textInputWithValue v = textInput def{ _textInputConfig_initialValue = v}

textAreaWithValue :: MonadWidget t m => Text -> m (TextArea t)
textAreaWithValue v = textArea def{_textAreaConfig_initialValue = v}

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



breakEl :: MonadWidget t m => m ()
breakEl = el "br" blank

titled :: MonadWidget t m => Text -> m a -> m a
titled title inner = do
  text title
  breakEl
  res <- inner
  breakEl
  pure res


divID :: MonadWidget t m => Text -> m a -> m a
divID id = elAttr "div" ("id" =: id)

divIDClass :: MonadWidget t m => Text -> Text -> m a -> m a
divIDClass id classes = elAttr "div" ("id" =: ( "#" <> id) <>
                                "class" =: classes)

{-| This is an abstraction for a widget that creates a list of contents.
-}
-- constructionTable :: MonadWidget t m => m (Event t i) -> m (Event t i) -> (i -> i -> Bool) -> [i] -> m (Dynamic t [i])
-- constructionTable createWidget listWidget
