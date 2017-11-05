{-| Author: Tomas Möre 2017

|-}

module Main where

import DQuest.Server (serveOn)


main :: IO ()
main = serveOn 8080
