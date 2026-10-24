module Main

import Data.List
import Data.String
import GeneratedName
import System
import System.Directory
import System.File
import Typegen

fail : String -> IO a
fail msg = do
  putStrLn ("FAIL: " ++ msg)
  exitFailure

assertEq : Eq a => Show a => String -> a -> a -> IO ()
assertEq label expected actual =
  if expected == actual
    then putStrLn ("ok " ++ label)
    else fail (label ++ ": expected " ++ show expected ++ " got " ++ show actual)

assertSuccess : String -> ExitCode -> IO ()
assertSuccess label ExitSuccess = putStrLn ("ok " ++ label)
assertSuccess label (ExitFailure n) =
  fail (label ++ ": expected success got " ++ show n)

assertFailure : String -> ExitCode -> IO ()
assertFailure label ExitSuccess = fail (label ++ ": expected failure got success")
assertFailure label (ExitFailure _) = putStrLn ("ok " ++ label)

covering
mkTempDir : IO String
mkTempDir = do
  (out, 0) <- run "mktemp -d /tmp/typegen-XXXXXX"
    | (_, n) => fail ("mktemp failed: " ++ show n)
  pure (trim out)

covering
ensureDir : String -> IO ()
ensureDir path = do
  Right () <- createDir path
    | Left err => fail ("createDir " ++ path ++ ": " ++ show err)
  pure ()

covering
listGenerated : String -> IO (List String)
listGenerated generatedDir = do
  Right names <- listDir generatedDir
    | Left err => fail ("listDir " ++ generatedDir ++ ": " ++ show err)
  pure names

covering
writeSchema : String -> String -> String -> IO ()
writeSchema schemaDir filename contents = do
  Right () <- writeFile (schemaDir ++ "/" ++ filename) contents
    | Left err => fail ("writeFile " ++ filename ++ ": " ++ show err)
  pure ()

covering
readGenerated : String -> String -> IO String
readGenerated generatedDir filename = do
  Right contents <- readFile (generatedDir ++ "/" ++ filename)
    | Left err => fail ("readFile " ++ filename ++ ": " ++ show err)
  pure contents

filmSchema : String
filmSchema = """
{
  "type": "object",
  "properties": {
    "title": {
      "type": "string"
    },
    "year": {
      "type": "number"
    }
  }
}
"""

covering
main : IO ()
main = do
  assertEq "filmSchema.json names FilmSchema"
    (Just ("FilmSchema", "FilmSchema"))
    (fromFilename "filmSchema.json")
  assertEq "user.json stem is User not User.json"
    (Just ("User", "User"))
    (fromFilename "user.json")
  assertEq "FilmSchema.json keeps leading uppercase"
    (Just ("FilmSchema", "FilmSchema"))
    (fromFilename "FilmSchema.json")
  assertEq "hyphen in filename is not a valid Idris identifier"
    Nothing
    (fromFilename "film-schema.json")
  assertEq "space in filename is not a valid Idris identifier"
    Nothing
    (fromFilename "film schema.json")
  assertEq "underscore in stem stays in the generated name"
    (Just ("Film_schema", "Film_schema"))
    (fromFilename "film_schema.json")
  assertEq "reserved Idris identifier Type is not valid"
    Nothing
    (fromFilename "Type.json")

  root <- mkTempDir
  let schemaDir = root ++ "/schemas"
  let generatedDir = root ++ "/generated"
  ensureDir schemaDir
  ensureDir generatedDir
  (code, _) <- runTypegen schemaDir generatedDir
  assertSuccess "empty schema directory succeeds" code
  names <- listGenerated generatedDir
  assertEq "empty schema directory writes nothing" [] names

  missingRoot <- mkTempDir
  let missingSchemas = missingRoot ++ "/schemas"
  let missingGenerated = missingRoot ++ "/generated"
  ensureDir missingSchemas
  (missingCode, _) <- runTypegen missingSchemas missingGenerated
  assertSuccess "creates generated-source directory when missing" missingCode
  missingNames <- listGenerated missingGenerated
  assertEq "missing generated-source directory is created empty" [] missingNames

  oneRoot <- mkTempDir
  let oneSchemas = oneRoot ++ "/schemas"
  let oneGenerated = oneRoot ++ "/generated"
  ensureDir oneSchemas
  writeSchema oneSchemas "filmSchema.json" filmSchema
  (oneCode, _) <- runTypegen oneSchemas oneGenerated
  assertSuccess "one valid schema succeeds" oneCode
  oneNames <- listGenerated oneGenerated
  assertEq "one valid schema writes one generated module" ["FilmSchema.idr"] oneNames
  oneSrc <- readGenerated oneGenerated "FilmSchema.idr"
  assertEq "generated module header is Generated.FilmSchema"
    True (isInfixOf "module Generated.FilmSchema" oneSrc)
  assertEq "generated module declares FilmSchema"
    True (isInfixOf "record FilmSchema" oneSrc)
  assertEq "generated types do not implement Cast"
    False (isInfixOf "Cast" oneSrc)

  underRoot <- mkTempDir
  let underSchemas = underRoot ++ "/schemas"
  let underGenerated = underRoot ++ "/generated"
  ensureDir underSchemas
  writeSchema underSchemas "film_schema.json" filmSchema
  (underCode, _) <- runTypegen underSchemas underGenerated
  assertSuccess "underscore schema filename succeeds" underCode
  underNames <- listGenerated underGenerated
  assertEq "underscore schema writes Film_schema.idr" ["Film_schema.idr"] underNames
  underSrc <- readGenerated underGenerated "Film_schema.idr"
  assertEq "generated module last segment matches the file stem"
    True (isInfixOf "module Generated.Film_schema" underSrc)

  severalRoot <- mkTempDir
  let severalSchemas = severalRoot ++ "/schemas"
  let severalGenerated = severalRoot ++ "/generated"
  ensureDir severalSchemas
  writeSchema severalSchemas "filmSchema.json" filmSchema
  writeSchema severalSchemas "user.json" """
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    }
  }
}
"""
  (severalCode, _) <- runTypegen severalSchemas severalGenerated
  assertSuccess "several valid schemas succeed" severalCode
  severalNames <- listGenerated severalGenerated
  assertEq "several valid schemas write one generated module each"
    ["FilmSchema.idr", "User.idr"] (sort severalNames)

  ignoreRoot <- mkTempDir
  let ignoreSchemas = ignoreRoot ++ "/schemas"
  let ignoreGenerated = ignoreRoot ++ "/generated"
  ensureDir ignoreSchemas
  writeSchema ignoreSchemas "filmSchema.json" filmSchema
  writeSchema ignoreSchemas "README.md" "# not a schema"
  writeSchema ignoreSchemas "notes.txt" "ignore me"
  ensureDir (ignoreSchemas ++ "/nested")
  writeSchema (ignoreSchemas ++ "/nested") "nested.json" filmSchema
  (ignoreCode, _) <- runTypegen ignoreSchemas ignoreGenerated
  assertSuccess "ignores nested JSON and non-JSON files" ignoreCode
  ignoreNames <- listGenerated ignoreGenerated
  assertEq "only top-level JSON becomes generated source"
    ["FilmSchema.idr"] ignoreNames

  badJsonRoot <- mkTempDir
  let badJsonSchemas = badJsonRoot ++ "/schemas"
  let badJsonGenerated = badJsonRoot ++ "/generated"
  ensureDir badJsonSchemas
  writeSchema badJsonSchemas "filmSchema.json" "{"
  (badJsonCode, badJsonLog) <- runTypegen badJsonSchemas badJsonGenerated
  assertFailure "malformed JSON fails the run" badJsonCode
  assertEq "malformed JSON logs malformed schema" ["malformed schema"] badJsonLog
  badJsonNames <- listGenerated badJsonGenerated
  assertEq "malformed JSON writes no generated module" [] badJsonNames

  notSchemaRoot <- mkTempDir
  let notSchemaSchemas = notSchemaRoot ++ "/schemas"
  let notSchemaGenerated = notSchemaRoot ++ "/generated"
  ensureDir notSchemaSchemas
  writeSchema notSchemaSchemas "filmSchema.json" "\"not a schema\""
  (notSchemaCode, notSchemaLog) <- runTypegen notSchemaSchemas notSchemaGenerated
  assertFailure "well-formed JSON that is not a schema fails the run" notSchemaCode
  assertEq "non-schema JSON logs malformed schema" ["malformed schema"] notSchemaLog
  notSchemaNames <- listGenerated notSchemaGenerated
  assertEq "non-schema JSON writes no generated module" [] notSchemaNames

  badNameRoot <- mkTempDir
  let badNameSchemas = badNameRoot ++ "/schemas"
  let badNameGenerated = badNameRoot ++ "/generated"
  ensureDir badNameSchemas
  writeSchema badNameSchemas "film-schema.json" filmSchema
  (badNameCode, badNameLog) <- runTypegen badNameSchemas badNameGenerated
  assertFailure "invalid Idris identifier in filename fails the run" badNameCode
  assertEq "invalid filename logs malformed schema" ["malformed schema"] badNameLog
  badNameNames <- listGenerated badNameGenerated
  assertEq "invalid filename writes no generated module" [] badNameNames

  leftoverRoot <- mkTempDir
  let leftoverSchemas = leftoverRoot ++ "/schemas"
  let leftoverGenerated = leftoverRoot ++ "/generated"
  ensureDir leftoverSchemas
  ensureDir leftoverGenerated
  Right () <- writeFile (leftoverGenerated ++ "/Leftover.idr") "module Generated.Leftover\n"
    | Left err => fail ("write leftover: " ++ show err)
  (leftoverCode, _) <- runTypegen leftoverSchemas leftoverGenerated
  assertSuccess "does not delete leftover generated source" leftoverCode
  leftoverNames <- listGenerated leftoverGenerated
  assertEq "leftover generated source remains" ["Leftover.idr"] leftoverNames
  leftoverSrc <- readGenerated leftoverGenerated "Leftover.idr"
  assertEq "leftover generated source is unchanged"
    "module Generated.Leftover\n" leftoverSrc

  overwriteRoot <- mkTempDir
  let overwriteSchemas = overwriteRoot ++ "/schemas"
  let overwriteGenerated = overwriteRoot ++ "/generated"
  ensureDir overwriteSchemas
  ensureDir overwriteGenerated
  writeSchema overwriteSchemas "filmSchema.json" filmSchema
  Right () <- writeFile (overwriteGenerated ++ "/FilmSchema.idr") "STALE\n"
    | Left err => fail ("write stale: " ++ show err)
  (overwriteCode, _) <- runTypegen overwriteSchemas overwriteGenerated
  assertSuccess "overwrites existing generated source" overwriteCode
  overwriteSrc <- readGenerated overwriteGenerated "FilmSchema.idr"
  assertEq "regeneration replaces stale generated source"
    True (isInfixOf "module Generated.FilmSchema" overwriteSrc)
  assertEq "stale generated source is gone"
    False (isInfixOf "STALE" overwriteSrc)

  stopRoot <- mkTempDir
  let stopSchemas = stopRoot ++ "/schemas"
  let stopGenerated = stopRoot ++ "/generated"
  ensureDir stopSchemas
  writeSchema stopSchemas "bad.json" "{"
  writeSchema stopSchemas "filmSchema.json" filmSchema
  (stopCode, stopLog) <- runTypegen stopSchemas stopGenerated
  assertFailure "stops on the first malformed schema" stopCode
  assertEq "first malformed schema logs malformed schema" ["malformed schema"] stopLog
  stopNames <- listGenerated stopGenerated
  assertEq "remaining schemas are not processed after the first malformed one"
    [] stopNames

  (gitOut, 0) <- run "git rev-parse --show-toplevel"
    | _ => fail "git rev-parse --show-toplevel failed"
  let justRoot = trim gitOut
  True <- changeDir justRoot
    | False => fail ("changeDir " ++ justRoot)
  True <- exists (justRoot ++ "/justfile")
    | False => fail "justfile not found"
  (showOut, showCode) <- run "just --show typegen"
  assertEq "just typegen is showable" 0 showCode
  assertEq "just typegen wraps pack run typegen.ipkg"
    True (isInfixOf "pack run typegen.ipkg" showOut)
  assertEq "just typegen takes no file argument"
    False (isInfixOf "{{" showOut)
  (typegenOut, typegenCode) <- run "just typegen"
  assertEq "just typegen on empty schemas succeeds" 0 typegenCode
  assertEq "just typegen does not log malformed schema on empty schemas"
    False (isInfixOf "malformed schema" typegenOut)
