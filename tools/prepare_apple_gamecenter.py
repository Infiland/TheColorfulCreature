#!/usr/bin/env python3
"""Prepare reviewable Game Center catalog metadata and original pixel-art icons."""

from __future__ import annotations

import csv
import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / "docs" / "release"
DRAW_FILE = ROOT / "objects" / "o_achievementbox" / "Draw_0.gml"
SOURCE_CATALOG = RELEASE / "apple-achievements.json"
OUTPUT_DIR = RELEASE / "gamecenter" / "achievements"
OUTPUT_JSON = RELEASE / "apple-achievements-reviewed.json"
OUTPUT_CSV = RELEASE / "apple-achievements-localization.csv"

RETIRED = {
    "EASTER_EGG": "No award call or content-data trigger exists in the current project.",
    "IT_HAPPENED": "No award call or content-data trigger exists in the current project.",
    "COOKIE_CLICKER": "No award call or content-data trigger exists in the current project.",
    "JEBAITED": "No award call or content-data trigger exists in the current project.",
}

# Achievements awarded through data-driven built-in challenge definitions.
CHALLENGE_CASES = {
    "KAIZO_CHALLENGE": 104,
    "BLIND_CHALLENGE": 124,
    "BIGROOM_CHALLENGE": 121,
    "WORLD_6": 115,
    "WORLD_7": 116,
    "INVISIBLE_CHALLENGE": 120,
    "TUTORIAL_CHALLENGE": 118,
    "LADDER_CHALLENGE": 119,
    "SLIPPERY_CHALLENGE": 122,
    "DOUBLEJUMP_CHALLENGE": 123,
    "TROOP_CHALLENGE": 125,
    "SPEED_CHALLENGE": 126,
    "WATER_CHALLENGE": 127,
    "MOVING_CHALLENGE": 128,
    "BREAKABLE_CHALLENGE": 129,
    "SPIKE_CHALLENGE": 130,
    "COMMUNITY_CHALLENGE": 131,
    "CORRUPTED_SPIKE_CHALLENGE": 132,
}

# The project uses a 1, 5, 11 Apple/Google tier subset of each 11-step stat family.
STAT_CASES = {
    "LEVEL_COMPLETION": lambda n: n,
    "DEATHS": lambda n: 11 + n,
    "COIN": lambda n: 22 + n,
    "JUMP": lambda n: 44 + n,
}

SPECIAL_CASES = {
    # This award is triggered at maximum Endless Run difficulty but omitted from the old UI list.
    "ABSOLUTE_ENDLESS_HELL": 85,
    "A_SMALL_LOAN": 76,
    "MONEY_SAVER": 77,
    "THE_GLITTERING_RICH": 78,
    "TORCHERD": 64,
    "HM_MEDIUM": 94,
    "HM_DIFFICULT": 95,
    "HM_INSANE": 96,
    "HM_RIDICULOUS": 97,
    "HM_IMPOSSIBLE": 98,
    "HM_YEAHGL": 99,
}

TITLE_FIXES = {
    "TROOP_CHALLENGE": "Dark Knight of the Troops",
    "POTATO_SETTINGS": "Potato Settings",
    "WORLD_6": "A World Revisited",
    "WORLD_7": "Buffed Spikes!",
    "THE_ANTI_DEATH": "The Anti-Death",
    "TORCHERD": "Torched",
    "ABSOLUTE_ENDLESS_HELL": "Absolute Endless Hell",
    "EASTEREGG_3": "Wrong-Way Platform",
}

DESC_FIXES = {
    "TROOP_CHALLENGE": "Beat the Troop Challenge.",
    "POTATO_SETTINGS": "Turn the graphics settings all the way down.",
    "WORLD_6": "Beat the World 6 Challenge.",
    "WORLD_7": "Beat the World 7 Challenge.",
    "COOKIE_CLICKER": "Bake one cookie.",
    "KAIZO_CHALLENGE": "Beat the Kaizo Challenge.",
    "ABSOLUTE_ENDLESS_HELL": "Reach the maximum Endless Run difficulty.",
}


def split_gml_args(text: str) -> list[str]:
    result: list[str] = []
    current: list[str] = []
    in_string = False
    escaped = False
    depth = 0
    for char in text:
        if in_string:
            current.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
            current.append(char)
        elif char == "(":
            depth += 1
            current.append(char)
        elif char == ")":
            depth -= 1
            current.append(char)
        elif char == "," and depth == 0:
            result.append("".join(current).strip())
            current = []
        else:
            current.append(char)
    if current:
        result.append("".join(current).strip())
    return result


def gml_string(value: str) -> str:
    try:
        return json.loads(value)
    except (json.JSONDecodeError, TypeError):
        return value.strip('"')


def draw_cases() -> dict[int, dict[str, object]]:
    cases: dict[int, dict[str, object]] = {}
    for line in DRAW_FILE.read_text(encoding="utf-8").splitlines():
        match = re.match(r"\s*case\((\d+)\):\s*draw_achievement\((.*)\)\s*break;", line)
        if not match:
            continue
        args = split_gml_args(match.group(2))
        if len(args) < 8:
            continue
        cases[int(match.group(1))] = {
            "sprite": args[0],
            "key": gml_string(args[1]) if args[1].startswith('"') else args[1],
            "hidden": args[3] == "1",
            "title": gml_string(args[4]),
            "description": gml_string(args[5]),
        }
    return cases


def sprite_frame(sprite_name: str) -> Path:
    matches = [path for path in (ROOT / "sprites").rglob(f"{sprite_name}.yy")
               if path.parent.name == sprite_name]
    if len(matches) != 1:
        raise RuntimeError(f"Expected one sprite resource for {sprite_name}; found {matches}")
    yy = matches[0]
    match = re.search(r'"frames"\s*:\s*\[\s*\{.*?"name"\s*:\s*"([^"]+)"',
                      yy.read_text(encoding="utf-8"), re.S)
    if not match:
        raise RuntimeError(f"No frame UUID in {yy}")
    frame = yy.parent / f"{match.group(1)}.png"
    if not frame.exists():
        raise RuntimeError(f"Sprite frame image missing: {frame}")
    return frame


def get_case_for_id(game_id: str, cases: dict[int, dict[str, object]]) -> int | None:
    for case, item in cases.items():
        if item["key"] == game_id:
            return case
    for family, case_fn in STAT_CASES.items():
        match = re.fullmatch(rf"{family}_(\d+)", game_id)
        if match:
            return case_fn(int(match.group(1)))
    return CHALLENGE_CASES.get(game_id, SPECIAL_CASES.get(game_id))


def main() -> None:
    candidates = json.loads(SOURCE_CATALOG.read_text(encoding="utf-8"))
    cases = draw_cases()
    source_files = [p for p in (ROOT / "scripts").rglob("*.gml")] + [
        p for p in (ROOT / "objects").rglob("*.gml")
    ] + [p for p in (ROOT / "rooms").rglob("*.gml")]
    source_text = "\n".join(p.read_text(encoding="utf-8", errors="ignore") for p in source_files)

    records: list[dict[str, object]] = []
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for candidate in candidates:
        game_id = candidate["game_id"]
        if game_id in RETIRED:
            continue
        case = get_case_for_id(game_id, cases)
        if case is None or case not in cases:
            raise RuntimeError(f"No original title, description, or icon found for {game_id}")
        # Named triggers must be awarded in GML or in the built-in challenge data.
        dynamically_awarded = game_id in CHALLENGE_CASES
        award_call = re.search(rf'achievement_award\(\s*"{re.escape(game_id)}"\s*\)', source_text)
        challenge_data = "\"achievement\"" in source_text and game_id in source_text
        if not award_call and not dynamically_awarded and not challenge_data:
            raise RuntimeError(f"Candidate is not awarded by current game source: {game_id}")

        source = cases[case]
        title = TITLE_FIXES.get(game_id, str(source["title"]).strip())
        description = DESC_FIXES.get(game_id, str(source["description"]).strip())
        if game_id == "LEVEL_COMPLETION_1":
            title = "Your Adventure Begins"
        if len(title) > 30:
            raise RuntimeError(f"Achievement title exceeds Apple's 30-character limit: {game_id}: {title}")
        if not description:
            raise RuntimeError(f"Missing description for {game_id}")

        apple_id = candidate["apple_id"]
        image_name = f"{game_id.lower()}.png"
        image_path = OUTPUT_DIR / image_name
        source_image = sprite_frame(str(source["sprite"]))
        subprocess.run(["sips", "-z", "1024", "1024", str(source_image), "--out", str(image_path)],
                       check=True, stdout=subprocess.DEVNULL)
        records.append({
            "game_id": game_id,
            "apple_id": apple_id,
            "reference_name": title,
            # The pre-existing First Steps draft is already valued at five points.
            "points": 5 if game_id == "LEVEL_COMPLETION_1" else 10,
            "hidden": bool(source["hidden"]) or game_id == "ABSOLUTE_ENDLESS_HELL",
            "achievable_more_than_once": False,
            "earned_description": f"{title} unlocked. {description}",
            "pre_earned_description": description,
            "image": str(image_path.relative_to(ROOT)),
            "source_image": str(source_image.relative_to(ROOT)),
            "source_case": case,
            "catalog_status": "draft asset prepared; not submitted for review",
        })

    if sum(int(x["points"]) for x in records) > 1000:
        raise RuntimeError("Achievement points exceed Apple's 1,000 point limit")

    OUTPUT_JSON.write_text(json.dumps({
        "source_candidates": len(candidates),
        "retired": RETIRED,
        "count": len(records),
        "total_points": sum(int(x["points"]) for x in records),
        "localization": "English (U.S.)",
        "achievements": records,
    }, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    with OUTPUT_CSV.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(records[0]))
        writer.writeheader()
        writer.writerows(records)
    print(f"Prepared {len(records)} achievements, {sum(int(x['points']) for x in records)} total points.")
    print(f"Reviewed JSON: {OUTPUT_JSON}")
    print(f"Localization CSV: {OUTPUT_CSV}")
    print(f"Icons: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
