import polars as pl

POKEMON_EXCEPTIONS: dict[str, str] = {
    # Gendered species
    "nidoranf": "nidoran-f",
    "nidoran♀": "nidoran-f",
    "nidoran-f": "nidoran-f",
    "nidoranm": "nidoran-m",
    "nidoran♂": "nidoran-m",
    "nidoran-m": "nidoran-m",
    # Common formatting / punctuation variants
    "mr mime": "mr-mime",
    "mr. mime": "mr-mime",
    "mime jr": "mime-jr",
    "mime jr.": "mime-jr",
    "type null": "type-null",
    "jangmo o": "jangmo-o",
    "hakamo o": "hakamo-o",
    "kommo o": "kommo-o",
    "tapu koko": "tapu-koko",
    "tapu lele": "tapu-lele",
    "tapu bulu": "tapu-bulu",
    "tapu fini": "tapu-fini",
}

MOVE_EXCEPTIONS: dict[str, str] = {
    # Hidden Power typed variants from Smogon stats keys
    "hiddenpowerbug": "hidden-power",
    "hiddenpowerdark": "hidden-power",
    "hiddenpowerdragon": "hidden-power",
    "hiddenpowerelectric": "hidden-power",
    "hiddenpowerfighting": "hidden-power",
    "hiddenpowerfire": "hidden-power",
    "hiddenpowerflying": "hidden-power",
    "hiddenpowerghost": "hidden-power",
    "hiddenpowergrass": "hidden-power",
    "hiddenpowerground": "hidden-power",
    "hiddenpowerice": "hidden-power",
    "hiddenpowerpoison": "hidden-power",
    "hiddenpowerpsychic": "hidden-power",
    "hiddenpowerrock": "hidden-power",
    "hiddenpowersteel": "hidden-power",
    "hiddenpowerwater": "hidden-power",
    # Smogon variant -> PokeAPI identifier
    "visegrip": "vice-grip",
    # Empty/invalid move keys seen in some dumps
    "": "unknown",
}


def _canonical_key(name: str) -> str:
    """Canonicalize names so Smogon/PokeAPI formatting differences collapse."""
    return (
        str(name)
        .lower()
        .replace("’", "")
        .replace("'", "")
        .replace(".", "")
        .replace(" ", "")
        .replace("-", "")
    )


def build_name_mapping(pokeapi_dir: str) -> dict[str, str]:
    """Build {canonical smogon display name -> pokeapi slug} from local CSVs."""
    species_names = pl.read_csv(f"{pokeapi_dir}/pokemon_species_names.csv")
    pokemon = pl.read_csv(f"{pokeapi_dir}/pokemon.csv")

    english = species_names.filter(pl.col("local_language_id") == 9).select(
        ["pokemon_species_id", "name"]
    )

    default_forms = pokemon.filter(pl.col("is_default") == 1).select(
        ["species_id", "identifier"]
    )

    joined = english.join(
        default_forms,
        left_on="pokemon_species_id",
        right_on="species_id",
    )

    mapping = {
        _canonical_key(row["name"]): row["identifier"]
        for row in joined.iter_rows(named=True)
    }

    # Add/override known aliases
    mapping.update(
        {_canonical_key(alias): slug for alias, slug in POKEMON_EXCEPTIONS.items()}
    )

    return mapping


def build_move_mapping(pokeapi_dir: str) -> dict[str, str]:
    """Build {canonical smogon move name -> pokeapi slug} from moves.csv."""
    moves = pl.read_csv(f"{pokeapi_dir}/moves.csv").select("identifier")

    mapping = {
        _canonical_key(row["identifier"]): row["identifier"]
        for row in moves.iter_rows(named=True)
    }

    mapping.update(
        {_canonical_key(alias): slug for alias, slug in MOVE_EXCEPTIONS.items()}
    )

    return mapping


def normalize_col(df: pl.DataFrame, col: str, mapping: dict[str, str]) -> pl.DataFrame:
    misses: set[str] = set()

    def normalize(name: str | None) -> str | None:
        if name is None:
            return None
        key = _canonical_key(name)
        slug = mapping.get(key)
        if slug is None:
            misses.add(str(name))
            return str(name).lower()
        return slug

    result = df.with_columns(
        pl.col(col).map_elements(normalize, return_dtype=pl.String)
    )

    if misses:
        preview = ", ".join(sorted(misses)[:5])
        ellipsis = "..." if len(misses) > 5 else ""
        print(f"    warn: {len(misses)} unresolved in '{col}': {preview}{ellipsis}")

    return result
