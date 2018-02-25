{-# LANGUAGE OverloadedStrings #-}
module Datasektionen.Zfinger where



import Data.Monoid
import Datasektionen.Types
import Data.String
import Data.Text (Text)

zfingerImgUrl :: KthID -> Text
zfingerImgUrl kthId =
  "http://zfinger.sips.datasektionen.se/user/" <> kthId <>  "/image"
