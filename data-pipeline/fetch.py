import requests

BASE_URL = "https://smogon.com/stats/"


def dates_in_range(from_date: str, to_date: str) -> list[str]:
    year, month = map(int, from_date.split("-"))
    end_year, end_month = map(int, to_date.split("-"))
    dates = []
    while (year, month) <= (end_year, end_month):
        dates.append(f"{year:04d}-{month:02d}")
        month += 1
        if month > 12:
            month = 1
            year += 1
    return dates


def fetch_smogon(stem: str, from_date: str, to_date: str) -> list[dict]:
    dates = dates_in_range(from_date, to_date)
    results = []

    with requests.Session() as session:
        for date in dates:
            print(f"  {date}... ", end="", flush=True)

            chaos_resp = session.get(f"{BASE_URL}{date}/chaos/{stem}.json")
            if chaos_resp.status_code == 404:
                print("not found, skipping")
                continue
            chaos_resp.raise_for_status()

            leads_resp = session.get(f"{BASE_URL}{date}/leads/{stem}.txt")
            if leads_resp.status_code == 404:
                print("leads not found, skipping")
                continue
            leads_resp.raise_for_status()

            print("ok")
            results.append(
                {
                    "date": date,
                    "chaos": chaos_resp.json(),
                    "leads": leads_resp.text,
                }
            )

    return results
