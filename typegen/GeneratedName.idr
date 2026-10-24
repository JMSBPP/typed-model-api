module GeneratedName

import Data.String

stemOf : String -> String
stemOf filename =
  if isSuffixOf ".json" filename
    then substr 0 (minus (length filename) 5) filename
    else filename

upperFirst : String -> String
upperFirst s =
  case unpack s of
    [] => s
    (c :: cs) => pack (toUpper c :: cs)

reservedIdrisTypeNames : List String
reservedIdrisTypeNames = ["Delay", "Force", "Inf", "Lazy", "Type"]

validIdrisIdent : String -> Bool
validIdrisIdent s =
  case unpack s of
    [] => False
    (c :: cs) =>
      isAlpha c
        && all (\x => isAlphaNum x || x == '_') cs
        && not (elem s reservedIdrisTypeNames)

export
fromFilename : String -> Maybe (String, String)
fromFilename filename =
  let named = upperFirst (stemOf filename) in
  if validIdrisIdent named then Just (named, named) else Nothing
