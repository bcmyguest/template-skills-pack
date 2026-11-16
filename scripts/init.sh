#!/usr/bin/env bash
# Turns a fresh copy of this template into a named project, then deletes itself.
#
#   scripts/init.sh <name> "<one-line description>" [owner]
#
# <name> is kebab-case (my-tool). It replaces the template name in kebab, snake
# and UPPER_SNAKE case in every tracked file; owner (default: the origin
# remote's owner, else bcmyguest) replaces bcmyguest. Every template ships this
# same script; only `tpl` differs.
set -euo pipefail
cd "$(dirname "$0")/.."

tpl=template-skills-pack

[ $# -ge 2 ] || { sed -n '2,9s/^# \{0,1\}//p' "$0" >&2; exit 2; }
[[ $1 =~ ^[a-z][a-z0-9-]*$ ]] || { echo "init: name must be kebab-case: $1" >&2; exit 2; }
remote_owner=$(git remote get-url origin 2>/dev/null | sed -nE 's#.*[:/]([^/]+)/[^/]+(\.git)?$#\1#p')
upper() { tr 'a-z-' 'A-Z_' <<<"$1"; }
export NAME=$1 DESC=$2 OWNER=${3:-${remote_owner:-bcmyguest}}
export SNAKE=${NAME//-/_} UPPER TPL=$tpl TPL_SNAKE=${tpl//-/_} TPL_UPPER
UPPER=$(upper "$NAME")
TPL_UPPER=$(upper "$tpl")

git ls-files -z | grep -zv '^scripts/init\.sh$' | xargs -0 perl -pi -e '
    s/\Q$ENV{TPL}\E/$ENV{NAME}/g;
    s/\Q$ENV{TPL_SNAKE}\E/$ENV{SNAKE}/g;
    s/\Q$ENV{TPL_UPPER}\E/$ENV{UPPER}/g;
    s/__DESCRIPTION__/$ENV{DESC}/g;
    s/bcmyguest/$ENV{OWNER}/g;
'
# Rename tracked paths that carry the template name.
git ls-files | { grep -F -e "$tpl" -e "$TPL_SNAKE" || true; } | while read -r path; do
    new=${path//$tpl/$NAME}
    new=${new//$TPL_SNAKE/$SNAKE}
    mkdir -p "$(dirname "$new")"
    git mv "$path" "$new"
done
# git mv leaves emptied directories behind.
find . -path ./.git -prune -o -type d -empty -print | xargs -r rmdir -p 2>/dev/null || true
# Drop the template-only README section.
perl -0pi -e 's/<!-- template:start -->.*?<!-- template:end -->\n?//s' README.md
git rm -q scripts/init.sh

# Refresh lockfiles that embed the project name.
if [ -f Cargo.toml ]; then cargo generate-lockfile; fi
if [ -f package-lock.json ]; then npm install --package-lock-only --ignore-scripts --no-audit --no-fund; fi
if [ -f uv.lock ]; then uv lock; fi
if [ -f pnpm-lock.yaml ]; then pnpm install --lockfile-only; fi
echo "init: $NAME ready. Review with git diff, then commit." >&2
