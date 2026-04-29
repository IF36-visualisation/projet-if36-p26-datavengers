import argparse
from datetime import datetime, timedelta

from fetch import fetch_smogon
from normalize import build_move_mapping, build_name_mapping, normalize_col
from output import write_output
from parse import parse_chaos, parse_leads

POKEMON_COLS: dict[str, list[str]] = {
    "usage": ["pokemon"],
    "moves": ["pokemon"],
    "teammates": ["pokemon", "teammate"],
    "checks": ["pokemon", "check"],
    "leads": ["pokemon"],
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch and process Smogon stats")
    parser.add_argument("--stem", required=True, help="Format stem, e.g. gen1ou-0")
    parser.add_argument(
        "--from", dest="from_date", default="2014-11", help="Start date YYYY-MM"
    )
    parser.add_argument(
        "--to",
        dest="to_date",
        default=(datetime.today() - timedelta(days=30)).strftime("%Y-%m"),
        help="End date YYYY-MM",
    )
    parser.add_argument(
        "--output", default="../data/processed", help="Output directory"
    )
    parser.add_argument(
        "--pokeapi", default="../data/pokeapi", help="PokeAPI CSV directory"
    )
    args = parser.parse_args()

    print(f"Building name mappings from {args.pokeapi}...")
    pokemon_mapping = build_name_mapping(args.pokeapi)
    move_mapping = build_move_mapping(args.pokeapi)
    print(
        f"  {len(pokemon_mapping)} Pokémon mapped, {len(move_mapping)} moves mapped\n"
    )

    print(f"Fetching {args.stem} — {args.from_date} to {args.to_date}...")
    raw = fetch_smogon(args.stem, args.from_date, args.to_date)
    print(f"  {len(raw)} month(s) fetched\n")

    print("Parsing and normalizing...")
    all_dfs = {k: [] for k in POKEMON_COLS}

    for item in raw:
        chaos_dfs = parse_chaos(item["chaos"], item["date"], args.stem)
        leads_df = parse_leads(item["leads"], item["date"], args.stem)

        for table, df in {**chaos_dfs, "leads": leads_df}.items():
            if df is not None:
                for col in POKEMON_COLS[table]:
                    df = normalize_col(df, col, pokemon_mapping)
                if table == "moves" and "move" in df.columns:
                    df = normalize_col(df, "move", move_mapping)
            all_dfs[table].append(df)

    print(f"\nWriting output to {args.output}...")
    write_output(all_dfs, args.output)
    print("Done.")


if __name__ == "__main__":
    main()
