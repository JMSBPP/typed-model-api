module Generated.FilmSchema

public export
record FilmSchema where
    constructor MkFilmSchema
    {default Nothing title : Maybe String}
    {default Nothing year : Maybe Double}
