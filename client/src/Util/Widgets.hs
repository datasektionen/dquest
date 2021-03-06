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

textShow :: (MonadWidget t m, Show a) => a -> m ()
textShow = text . Text.pack . show


-- | Widget for foldable containers. Provides a header whth a folding
-- indicator. When the header is clicked the content is shown / hidden
foldWidget  :: MonadWidget t m => Text -> Bool -> m a -> m a
foldWidget title defaultFolded content = divClass "fold-wrapper" $ do
  rec (headerElem, foldedD) <- elAttr' "div" headerAttr $ do
        let clickEvent = domEvent Click headerElem
        foldedDyn <- foldDyn (\ _ prev -> not prev) defaultFolded clickEvent
        let arrowDyn = fmap (\ b -> if b then  "▲" else "▼") foldedDyn
        el "h3"  $ dynText (fmap (<> " " <> title) arrowDyn)
        pure foldedDyn
  let containerAttrDyn = (mappend defaultAttr) . foldedAttr <$> foldedD
      defaultAttr = "class" =: "fold-content"
  elDynAttr "div" containerAttrDyn content

  where
    foldedAttr True = "style" =: "display: none;"
    foldedAttr False = mempty
    headerAttr = mconcat ["class" =:  "fold-header"
                         , "style" =: ""]
