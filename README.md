# template-skills-pack

__DESCRIPTION__

<!-- template:start -->
## Using this template

```bash
gh repo create my-skills --template bcmyguest/template-skills-pack --private --clone
cd my-skills
scripts/init.sh my-skills "One-line description"
git add -A && git commit -m "chore: init from template-skills-pack"
pre-commit install --install-hooks --hook-type pre-commit --hook-type commit-msg
```

`init.sh` renames `template-skills-pack` everywhere, fills the description,
sets the owner from the `origin` remote, removes this section and deletes
itself. Replace `skills/hello/` with real skills.

Installing by repo URL needs read access, so other people can install only
once the repo is public.
<!-- template:end -->

## Install

Claude Code plugin:

```text
/plugin marketplace add bcmyguest/template-skills-pack
/plugin install template-skills-pack@template-skills-pack
```

Any agent that reads skills (via [skills.sh](https://skills.sh)):

```bash
npx skills add bcmyguest/template-skills-pack
```

## Skills

| Skill | Use |
|---|---|
| `hello` | Sample; replace it. |

## License

Apache-2.0
