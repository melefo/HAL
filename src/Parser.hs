--
-- EPITECH PROJECT, 2021
-- B-FUN-501-NAN-5-1-HAL-victor.trencic [WSL: Ubuntu]
-- File description:
-- Parser
--

module Parser where
import Control.Applicative
import Data.Char

newtype Error = Error String
    deriving Show

type Data a = String -> Either (a, String) Error

newtype Parser a = Parser {
    parse :: Data a
}

functorParser :: (a -> b) -> Parser a -> Data b
functorParser _ _ [] = Right (Error [])
functorParser fct parser str = case parse parser str of
    Left (a, res) -> Left (fct a, str)
    Right err -> Right err

instance Functor Parser where
    fmap fct parser =
        Parser (functorParser fct parser)

applicativeParser :: Parser (a -> b) -> Parser a -> Data b
applicativeParser _ _ [] = Right (Error [])
applicativeParser fct parser str = case parse parser str of
    Right err -> Right err
    Left (a, res) -> case parse fct res of
        Right err -> Right err
        Left (b, final) -> Left (b a, final)

funcParserBind :: Parser a -> (a -> Parser b) -> Data b
funcParserBind parser fct str = case parse parser str of
        Right err -> Right err
        Left (a, res) -> parse (fct a) res

parserBind :: Parser a -> (a -> Parser b) -> Parser b
parserBind parser fct = Parser (funcParserBind parser fct)

instance Applicative Parser where
    pure a = Parser (\x -> Left (a, x))
    (<*>) fct parser = Parser (applicativeParser fct parser)
    p1 *> p2 = p1 `parserBind` const p2

monadParser :: Parser a -> (a -> Parser b) -> Data b
monadParser _ _ [] = Right (Error [])
monadParser parser fct str = case parse parser str of
    Right err -> Right err
    Left (a, res) -> case parse (fct a) res of
        Right err -> Right err
        final@(Left b) -> final

instance Monad Parser where
    (>>=) parser fct = Parser (monadParser parser fct)
    (>>) = (*>)

alternativeParser :: Parser a -> Parser a -> Data a
alternativeParser _ _ [] = Right (Error [])
alternativeParser p1 p2 str
    | Right (Error err1) <- parse p1 str
    , Right (Error err2) <- parse p2 str =
        Right (Error (err1 ++ err2))
    | Right err <- parse p1 str =
        parse p2 str
    | otherwise = parse p1 str

funcMany :: Parser a -> Data [a]
funcMany parser str = case parse parser str of
    Left (a, str) -> case funcMany parser str of
        Left (b, final) -> Left (a : b, final)
        Right err -> Left ([a], str)
    Right err -> Right err

instance Alternative Parser where
    empty = Parser (Right . Error)
    (<|>) f1 f2 = Parser (alternativeParser f1 f2)
    many parser = Parser (funcMany parser)
