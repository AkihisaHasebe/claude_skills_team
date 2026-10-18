#!/usr/bin/env bash
# Install the /team skill set into ~/.claude (Linux / macOS).
# Existing files are backed up to ~/.claude/backups/team-<timestamp>/ before being overwritten.
#   bash install.sh
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst="${HOME}/.claude"
files=("skills/team/SKILL.md" "agents/team-worker.md" "agents/team-reviewer.md")
backup="${dst}/backups/team-$(date +%Y%m%d-%H%M%S)"
backed_up=0

for f in "${files[@]}"; do
    target="${dst}/${f}"
    if [ -e "${target}" ]; then
        mkdir -p "$(dirname "${backup}/${f}")"
        cp "${target}" "${backup}/${f}"
        backed_up=1
    fi
    mkdir -p "$(dirname "${target}")"
    cp "${src}/${f}" "${target}"
    echo "installed: ${target}"
done
if [ "${backed_up}" -eq 1 ]; then echo "backup: ${backup}"; fi
echo "Restart Claude Code to use /team."
