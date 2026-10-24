module Main

import Generated.FilmSchema
import Hedgehog

filmSchemaCases : List (String, Property)
filmSchemaCases =
  [ ( "constructor applies"
    , property1 $ do
        let film = MkFilmSchema
        film.title === Nothing
    )
  , ( "title field"
    , property1 $ do
        let film = MkFilmSchema { title = Just "Heat" }
        film.title === Just "Heat"
    )
  , ( "year field"
    , property1 $ do
        let film = MkFilmSchema { year = Just 1995.0 }
        film.year === Just 1995.0
    )
  ]

filmSchemaGroup : Group
filmSchemaGroup =
  MkGroup "FilmSchema"
    (map (\(name, prop) => (fromString name, prop)) filmSchemaCases)

covering
main : IO ()
main = test [ filmSchemaGroup ]
