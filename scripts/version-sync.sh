#!/usr/bin/env bash
# Checks the plugin version agrees in plugin.json and marketplace.json, and,
# given a tag, that the tag names that version. release.yml and
# prepare-release.yml run it before anything is pushed.
#
#   scripts/version-sync.sh           # plugin.json == marketplace.json
#   scripts/version-sync.sh v0.2.0    # ... and == the tag
set -euo pipefail
cd "$(dirname "$0")/.."

plugin=$(jq -r .version .claude-plugin/plugin.json)
market=$(jq -r .metadata.version .claude-plugin/marketplace.json)

echo "plugin.json:      $plugin"
echo "marketplace.json: $market"
rc=0
[ "$plugin" = "$market" ] || { echo "error: marketplace.json has $market, plugin.json has $plugin" >&2; rc=1; }
if [ $# -ge 1 ]; then
    echo "tag:              ${1#v}"
    [ "$plugin" = "${1#v}" ] || { echo "error: tag $1 does not match plugin.json $plugin" >&2; rc=1; }
fi
[ $rc -eq 0 ] && echo "ok: $plugin"
exit $rc
