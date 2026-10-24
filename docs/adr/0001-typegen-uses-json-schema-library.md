# Typegen uses the json-schema library

The json-schema CLI always writes `.idr` next to the `.json`, so targeting `src/Generated/` would mean generate-then-move. Typegen uses the library (`compileSchema` + `writeFile`) instead, because generated source already depends on that library for some features and the two-directory layout is then a direct write.
