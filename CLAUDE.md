# CLAUDE.md

template-skills-pack: __DESCRIPTION__

## Layout

- `skills/<name>/SKILL.md`: one folder per skill. Frontmatter `name` equals
  the folder name; `description` says what the skill does and when to use it.
- `skills.sh.json`: groups the skills for `npx skills`. List every skill once.
- `.claude-plugin/plugin.json` + `marketplace.json`: the Claude Code plugin.

Adding a skill: create the folder, add it to `skills.sh.json` and to the
README table.

## Commands

```bash
python3 scripts/check-skills.py   # frontmatter, names, skills.sh.json coverage
scripts/version-sync.sh           # plugin.json == marketplace.json
claude plugin validate .          # Claude's own manifest check (local only)
```

Pre-commit enforces Conventional Commits; commit types set the release version.

## Releases

Run the **Prepare release** workflow on `main` (tick `dry_run` to preview).
It computes the next version with git-cliff, bumps both manifests, tags
`vX.Y.Z` and dispatches `release.yml`, which publishes a GitHub release with
the notes. Never bump the version by hand.
