module Main

import Data.String
import GeneratedName
import Hedgehog
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

userSchema : String
userSchema = """
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    }
  }
}
"""

fromFilenameCases : List (String, String, Maybe (String, String))
fromFilenameCases =
  [ ("filmSchema.json names FilmSchema", "filmSchema.json", Just ("FilmSchema", "FilmSchema"))
  , ("user.json stem is User not User.json", "user.json", Just ("User", "User"))
  , ("FilmSchema.json keeps leading uppercase", "FilmSchema.json", Just ("FilmSchema", "FilmSchema"))
  , ("hyphen in filename is not a valid Idris identifier", "film-schema.json", Nothing)
  , ("space in filename is not a valid Idris identifier", "film schema.json", Nothing)
  , ("underscore in stem stays in the generated name", "film_schema.json", Just ("Film_schema", "Film_schema"))
  , ("reserved Idris identifier Type is not valid", "Type.json", Nothing)
  ]

generatedNameGroup : Group
generatedNameGroup =
  MkGroup "GeneratedName"
    (map (\(name, filename, expected) =>
            (fromString name, property1 $ fromFilename filename === expected))
         fromFilenameCases)

compileOneSourceCases : List (String, String, String, List String, List String)
compileOneSourceCases =
  [ ( "one valid schema source"
    , "filmSchema.json"
    , filmSchema
    , ["module Generated.FilmSchema", "record FilmSchema"]
    , ["Cast"]
    )
  ]

compileOneMalformedCases : List (String, String, String)
compileOneMalformedCases =
  [ ("malformed JSON", "filmSchema.json", "{")
  , ("well-formed JSON that is not a schema", "filmSchema.json", "\"not a schema\"")
  , ("invalid Idris identifier in the filename", "film-schema.json", filmSchema)
  ]

compileOneGroup : Group
compileOneGroup =
  MkGroup "compileOne"
    ( map (\(name, filename, json, required, forbidden) =>
            ( fromString name
            , property1 $
                case compileOne filename json of
                  Left err => failWith Nothing err
                  Right src => do
                    traverse_ (\needle => isInfixOf needle src === True) required
                    traverse_ (\needle => isInfixOf needle src === False) forbidden
            ))
         compileOneSourceCases
    ++ map (\(name, filename, json) =>
            ( fromString name
            , property1 $ compileOne filename json === Left "malformed schema"
            ))
         compileOneMalformedCases
    )

schemaFilesCases : List (String, List String, List String)
schemaFilesCases =
  [ ("empty list writes nothing", [], [])
  , ("several json names are kept and sorted", ["user.json", "filmSchema.json"], ["filmSchema.json", "user.json"])
  , ("non-JSON names dropped", ["filmSchema.json", "README.md", "notes.txt", "nested"], ["filmSchema.json"])
  ]

schemaFilesGroup : Group
schemaFilesGroup =
  MkGroup "schemaFiles"
    (map (\(name, entries, expected) =>
            (fromString name, property1 $ schemaFiles entries === expected))
         schemaFilesCases)

compileAllEmptyCases : List (String, List (String, String), Either String (List (String, String)))
compileAllEmptyCases =
  [ ("empty list writes nothing", [], Right [])
  ]

compileAllModuleCases : List (String, List (String, String), List String)
compileAllModuleCases =
  [ ( "several valid schemas"
    , [("filmSchema.json", filmSchema), ("user.json", userSchema)]
    , ["FilmSchema", "User"]
    )
  ]

compileAllMalformedCases : List (String, List (String, String))
compileAllMalformedCases =
  [ ( "first malformed stops and remaining schemas are not compiled"
    , [("bad.json", "{"), ("filmSchema.json", filmSchema)]
    )
  ]

compileAllGroup : Group
compileAllGroup =
  MkGroup "compileAll"
    ( map (\(name, inputs, expected) =>
            (fromString name, property1 $ compileAll inputs === expected))
         compileAllEmptyCases
    ++ map (\(name, inputs, moduleLasts) =>
            ( fromString name
            , property1 $
                case compileAll inputs of
                  Left err => failWith Nothing err
                  Right pairs => map fst pairs === moduleLasts
            ))
         compileAllModuleCases
    ++ map (\(name, inputs) =>
            ( fromString name
            , property1 $ compileAll inputs === Left "malformed schema"
            ))
         compileAllMalformedCases
    )

covering
remainingIo : IO ()
remainingIo = do
  missingRoot <- mkTempDir
  let missingSchemas = missingRoot ++ "/schemas"
  let missingGenerated = missingRoot ++ "/generated"
  ensureDir missingSchemas
  (missingCode, _) <- runTypegen missingSchemas missingGenerated
  assertSuccess "creates generated-source directory when missing" missingCode
  missingNames <- listGenerated missingGenerated
  assertEq "missing generated-source directory is created empty" [] missingNames

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

covering
main : IO ()
main = do
  remainingIo
  test [ generatedNameGroup, compileOneGroup, schemaFilesGroup, compileAllGroup ]
