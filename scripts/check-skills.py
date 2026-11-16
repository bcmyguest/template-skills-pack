#!/usr/bin/env python3
"""Validates the skills and manifests. Exits 1 on any problem.

- Each skills/<dir>/SKILL.md opens with YAML frontmatter whose `name` equals
  <dir> (lowercase letters, digits, hyphens; at most 64 chars) and whose
  `description` is non-empty and at most 1024 chars.
- skills.sh.json lists every skill exactly once and nothing else.
- .claude-plugin/*.json parse.
"""

import json
import re
import sys
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
MAX_NAME = 64
MAX_DESCRIPTION = 1024

root = Path(__file__).resolve().parent.parent
errors: list[str] = []


def frontmatter(path: Path) -> dict[str, str]:
    """Top-level `key: value` pairs of the leading --- block."""
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        raise ValueError("no frontmatter: first line must be ---")
    fields: dict[str, str] = {}
    for line in lines[1:]:
        if line == "---":
            return fields
        m = re.match(r"^([A-Za-z_-]+):\s*(.*)$", line)
        if m:
            fields[m[1]] = m[2].strip().strip("\"'")
    raise ValueError("frontmatter never closes with ---")


skills: list[str] = []
for d in sorted(p for p in (root / "skills").iterdir() if p.is_dir()):
    rel = d.relative_to(root)
    skill_md = d / "SKILL.md"
    if not skill_md.is_file():
        errors.append(f"{rel}: missing SKILL.md")
        continue
    try:
        fm = frontmatter(skill_md)
    except ValueError as e:
        errors.append(f"{rel}/SKILL.md: {e}")
        continue
    name, desc = fm.get("name", ""), fm.get("description", "")
    if name != d.name:
        errors.append(f"{rel}/SKILL.md: name {name!r} must equal the folder name {d.name!r}")
    if not NAME_RE.match(d.name) or len(d.name) > MAX_NAME:
        errors.append(f"{rel}: folder name must be lowercase-hyphenated, at most {MAX_NAME} chars")
    if not desc:
        errors.append(f"{rel}/SKILL.md: description is empty")
    elif len(desc) > MAX_DESCRIPTION:
        errors.append(f"{rel}/SKILL.md: description is {len(desc)} chars, limit {MAX_DESCRIPTION}")
    skills.append(d.name)

listed = [s for g in json.loads((root / "skills.sh.json").read_text())["groupings"] for s in g["skills"]]
for s in sorted(set(listed) - set(skills)):
    errors.append(f"skills.sh.json lists {s!r}, which has no skills/{s}/")
for s in sorted(set(skills) - set(listed)):
    errors.append(f"skills/{s}/ is missing from skills.sh.json groupings")
for s in sorted({s for s in listed if listed.count(s) > 1}):
    errors.append(f"skills.sh.json lists {s!r} more than once")

for manifest in sorted((root / ".claude-plugin").glob("*.json")):
    try:
        json.loads(manifest.read_text())
    except json.JSONDecodeError as e:
        errors.append(f"{manifest.relative_to(root)}: {e}")

for e in errors:
    print(f"error: {e}", file=sys.stderr)
if errors:
    sys.exit(1)
print(f"ok: {len(skills)} skill(s)")
