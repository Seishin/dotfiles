#!/usr/bin/env bash
# Recreate closed cmux workspace tabs from dotfiles/cmux/cmux.json.
# Run this INSIDE cmux (socket control is limited to cmux-spawned processes).
# Idempotent: already-open tabs are skipped. Symlinked as ~/.local/bin/cmux-restore.
set -u

# Resolve the cmux CLI: in-app PATH, app bundle, or ~/.local/bin
CMUX_BIN="$(command -v cmux 2>/dev/null || true)"
if [[ -z "$CMUX_BIN" || ! -x "$CMUX_BIN" ]]; then
  for c in "/Applications/cmux.app/Contents/Resources/bin/cmux" "$HOME/.local/bin/cmux"; do
    [[ -x "$c" ]] && { CMUX_BIN="$c"; break; }
  done
fi
[[ -n "${CMUX_BIN:-}" ]] || { echo "cmux CLI not found" >&2; exit 1; }

CFG="${1:-$HOME/.config/cmux/cmux.json}"

python3 - "$CMUX_BIN" "$CFG" <<'PYEOF'
import json, os, subprocess, sys

cmux_bin, path = sys.argv[1], sys.argv[2]
d = json.load(open(path))
home = os.path.expanduser("~")

try:
    out = subprocess.run([cmux_bin, "workspace", "list", "--json"],
                         capture_output=True, text=True, timeout=10).stdout
    rows = json.loads(out)
    existing = {w.get("name") for w in rows if isinstance(w, dict)}
except Exception:
    existing = set()

created = []
for c in d.get("commands", []):
    ws = c.get("workspace") or {}
    name = ws.get("name") or c.get("name") or "workspace"
    if name in existing:
        print(f"skip (already open): {name}")
        continue
    # Allow a different username on a new machine: rewrite the old absolute prefix.
    cwd = (ws.get("cwd") or home).replace("/Users/seishin", home)
    layout = json.dumps(ws.get("layout")).replace("/Users/seishin", home)
    r = subprocess.run([cmux_bin, "new-workspace", "--name", name,
                        "--cwd", cwd, "--layout", layout],
                       capture_output=True, text=True)
    if r.returncode == 0:
        created.append(name)
        print(f"created tab: {name}")
    else:
        print(f"FAILED: {name}: {r.stderr.strip()}")

print(f"\n= Created {len(created)} tab(s): {', '.join(created) or 'none (all already open)'}")
print("= Switch tabs: Cmd+1..9 or click the sidebar.")
PYEOF