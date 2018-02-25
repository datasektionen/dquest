{-# LANGUAGE OverloadedStrings #-}
module DQuest.Util where



import Data.Monoid
import Reflex.Dom
import Datasektionen.Types (KthID)
import Datasektionen.Zfinger


kthPic :: MonadWidget t m => KthID -> m ()
kthPic kthId =
  elAttr "div" ( "class" =: "kth-pic" <>
                 "style" =:  cssStyle <>
                 "class" =: "profile-pic") blank
  where
    cssStyle = "background: url('" <> url <> "');"
    url = zfingerImgUrl kthId
