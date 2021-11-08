--
-- EPITECH PROJECT, 2021
-- B-FUN-501-NAN-5-1-HAL-victor.trencic [WSL: Ubuntu]
-- File description:
-- Hal
--

module Hal where

import Errors
import Control.Exception
import Debug.Trace
import GHC.IO.Handle
import GHC.IO.Handle.FD
import Parser
import Basic

readExpr :: String -> String
readExpr [] = []
readExpr input = case parse (spaces >> symbol) input of
    Left x -> "Found value"
    Right (Error err) -> "No match " ++ err

prompt :: IO String
prompt = do
    putStr "> "
    hFlush stdout
    getLine

interactive :: IO ()
interactive = do
    line <- prompt
    putStrLn $ readExpr line
    interactive

hal :: [String] -> IO ()
hal [] = interactive
hal args = pure ()