from pathlib import Path

import polars as pl


def write_output(
    all_dfs: dict[str, list[pl.DataFrame | None]], output_dir: str
) -> None:
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    for name, dfs in all_dfs.items():
        dfs = [df for df in dfs if df is not None]
        if not dfs:
            continue
        combined = pl.concat(dfs, how="diagonal_relaxed")

        path = out / f"smogon_{name}.parquet"
        combined.write_parquet(path)
        print(f"  smogon_{name}.parquet — {len(combined):,} rows")
