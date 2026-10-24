module Typegen

import Data.List
import Data.String
import GeneratedName
import Language.JSON
import JSONSchema.Compiler
import JSONSchema.Data
import JSONSchema.Names
import JSONSchema.Parser as SchemaParser
import System
import System.Directory
import System.File

covering
ensureGeneratedDir : String -> IO (ExitCode, List String)
ensureGeneratedDir generatedDir = do
  Right () <- createDir generatedDir
    | Left FileExists => pure (ExitSuccess, [])
    | Left _ => pure (ExitFailure 1, [])
  pure (ExitSuccess, [])

covering
malformed : IO (ExitCode, List String)
malformed = pure (ExitFailure 1, ["malformed schema"])

covering
replaceAll : (needle : String) -> (replacement : String) -> String -> String
replaceAll needle replacement str =
  if needle == "" then str else pack $ go (unpack str)
  where
    covering
    go : List Char -> List Char
    go [] = []
    go xs =
      let n = unpack needle in
      if isPrefixOf n xs
        then unpack replacement ++ go (drop (length n) xs)
        else case xs of
          [] => []
          (c :: rest) => c :: go rest

covering
namedSource : (moduleLast : String) -> (typeName : String) -> String -> String
namedSource moduleLast typeName src =
  let libraryType = show (asIdrisTypeName typeName) in
  if libraryType == typeName then src else replaceAll libraryType typeName src

export
covering
compileOne : (filename : String) -> (jsonText : String) -> Either String String
compileOne filename jsonText =
  let Just (moduleLast, typeName) = fromFilename filename
        | Nothing => Left "malformed schema"
      Just json = JSON.parse jsonText
        | Nothing => Left "malformed schema"
      jsonCasts = False
      opts = MkCompileOptions
        (asIdrisQTypeName ("Generated." ++ moduleLast))
        (asIdrisTypeName typeName)
        jsonCasts
      Just schema = SchemaParser.parse json @{opts}
        | Nothing => Left "malformed schema"
  in Right $ namedSource moduleLast typeName $
       concat $ intersperse "\n" $ compileSchema schema @{opts}

covering
processOne : (schemaDir : String) -> (generatedDir : String) -> (filename : String) -> IO (ExitCode, List String)
processOne schemaDir generatedDir filename = do
  Right jsonStr <- readFile (schemaDir ++ "/" ++ filename)
    | Left _ => malformed
  let Right src = compileOne filename jsonStr
    | Left msg => pure (ExitFailure 1, [msg])
  let Just (moduleLast, _) = fromFilename filename
    | Nothing => malformed
  Right () <- writeFile (generatedDir ++ "/" ++ moduleLast ++ ".idr") src
    | Left _ => malformed
  pure (ExitSuccess, [])

covering
processAll : (schemaDir : String) -> (generatedDir : String) -> List String -> IO (ExitCode, List String)
processAll _ _ [] = pure (ExitSuccess, [])
processAll schemaDir generatedDir (filename :: rest) = do
  (ExitSuccess, _) <- processOne schemaDir generatedDir filename
    | fail => pure fail
  processAll schemaDir generatedDir rest

export
covering
runTypegen : (schemaDir : String) -> (generatedDir : String) -> IO (ExitCode, List String)
runTypegen schemaDir generatedDir = do
  (ExitSuccess, _) <- ensureGeneratedDir generatedDir
    | fail => pure fail
  Right entries <- listDir schemaDir
    | Left _ => malformed
  let schemas = sort $ filter (isSuffixOf ".json") entries
  processAll schemaDir generatedDir schemas

export
covering
main : IO ()
main = do
  (code, logged) <- runTypegen "schemas" "src/Generated"
  traverse_ putStrLn logged
  exitWith code
