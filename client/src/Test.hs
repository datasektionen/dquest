{-# LANGUAGE OverloadedStrings #-}
module Test where

import Reflex.Dom

basic = mainWidget $ el "div" $ text "Welcome to Reflex"
