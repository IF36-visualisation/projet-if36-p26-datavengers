import polars as pl


def parse_chaos(data: dict, date: str, stem: str) -> dict[str, pl.DataFrame]:
    n_battles = data["info"]["number of battles"]
    poke = data["data"]

    # --- usage: flat scalars, one row per pokemon ---
    usage = pl.from_dicts(
        [
            {
                "date": date,
                "stem": stem,
                "pokemon": name,
                "usage_pct": stats.get("usage", 0.0),
                "raw_count": stats.get("Raw count", 0),
                "viability_ceiling": stats.get("Viability Ceiling"),
                "n_battles": n_battles,
            }
            for name, stats in poke.items()
        ]
    )

    # --- moves: wide (one col per move) → unpivot to long ---
    moves = (
        pl.from_dicts(
            [
                {"pokemon": name, **stats.get("Moves", {})}
                for name, stats in poke.items()
            ]
        )
        .with_columns(pl.lit(date).alias("date"), pl.lit(stem).alias("stem"))
        .unpivot(
            index=["date", "stem", "pokemon"],
            variable_name="move",
            value_name="usage_pct",
        )
        .drop_nulls("usage_pct")
        .with_columns(pl.col("move").cast(pl.String))
        .filter(pl.col("move").is_not_null())
        .filter(pl.col("move").str.strip_chars() != "")
    )

    # --- teammates: same pattern ---
    teammates = (
        pl.from_dicts(
            [
                {"pokemon": name, **stats.get("Teammates", {})}
                for name, stats in poke.items()
            ]
        )
        .with_columns(pl.lit(date).alias("date"), pl.lit(stem).alias("stem"))
        .unpivot(
            index=["date", "stem", "pokemon"],
            variable_name="teammate",
            value_name="correlation",
        )
        .drop_nulls("correlation")
        .filter(pl.col("teammate") != "empty")
    )

    # --- checks: values are [score, pct_ko, pct_switched] lists ---
    checks = (
        pl.from_dicts(
            [
                {
                    "pokemon": name,
                    **(stats.get("Checks and Counters", {}) or {}),
                }
                for name, stats in poke.items()
            ]
        )
        .with_columns(pl.lit(date).alias("date"), pl.lit(stem).alias("stem"))
        .unpivot(
            index=["date", "stem", "pokemon"],
            variable_name="check",
            value_name="values",
        )
        .drop_nulls("values")
    )

    if str(checks.schema["values"]).startswith("List"):
        checks = checks.filter(pl.col("values").list.len() >= 3)
    else:
        checks = checks.filter(pl.lit(False))

    if checks.height > 0:
        checks = checks.with_columns(
            pl.col("values").list.get(0).alias("score"),
            pl.col("values").list.get(1).alias("pct_ko"),
            pl.col("values").list.get(2).alias("pct_switched"),
        ).drop("values")
    else:
        checks = checks.with_columns(
            [
                pl.lit(None, dtype=pl.Float64).alias("score"),
                pl.lit(None, dtype=pl.Float64).alias("pct_ko"),
                pl.lit(None, dtype=pl.Float64).alias("pct_switched"),
            ]
        ).drop("values")

    return {"usage": usage, "moves": moves, "teammates": teammates, "checks": checks}


def parse_leads(text: str, date: str, stem: str) -> pl.DataFrame | None:
    rows = []
    total_leads = None

    for line in text.strip().splitlines():
        line = line.strip()

        if "Total leads" in line:
            total_leads = int(line.split(":")[1].strip())
            continue

        # skip separators and the header row
        if not line.startswith("|") or "Rank" in line:
            continue

        parts = [p.strip() for p in line.strip("|").split("|")]
        if len(parts) < 4:
            continue

        try:
            rows.append(
                {
                    "date": date,
                    "stem": stem,
                    "rank": int(parts[0]),
                    "pokemon": parts[1],
                    "usage_pct": float(parts[2].replace("%", "")) / 100,
                    "raw_count": int(parts[3]),
                    "total_leads": total_leads,
                }
            )
        except ValueError:
            continue

    return pl.DataFrame(rows) if rows else None
