{-# LANGUAGE OverloadedStrings #-}
module Frontend.UI where


import Reflex.DOM


root = mainWidget $ testButton


testButton = el "div" $ do
  t <- texInput def
  dynText $ _textInput_value t
