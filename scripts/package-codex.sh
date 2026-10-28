#!/usr/bin/env bash
# Builds dist/nimbus-codex.zip, the package uploaded to the OpenAI plugin submission portal.
# Only Codex files go in: the Claude Code manifest and its .mcp.json are left out, and
# codex.mcp.json ships as .mcp.json (the Codex default location). Only the assets the
# manifest references are included.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$ROOT/plugins/nimbus" "$ROOT/dist/nimbus-codex.zip" <<'PY'
import json, struct, sys, zipfile
from pathlib import Path

plugin, out = Path(sys.argv[1]), Path(sys.argv[2])
manifest = json.loads((plugin / ".codex-plugin/plugin.json").read_text())
iface = manifest["interface"]
errors = []

for key in ("displayName", "shortDescription"):
    if len(iface[key]) > 30:
        errors.append(f"interface.{key} is longer than 30 characters")
if len(iface.get("defaultPrompt", [])) > 3:
    errors.append("interface.defaultPrompt has more than 3 prompts")
for key in ("logo", "composerIcon"):
    path = plugin / iface[key]
    if not path.is_file():
        errors.append(f"interface.{key}: {iface[key]} is missing")
        continue
    data = path.read_bytes()
    if path.stat().st_size > 5 * 1024 * 1024:
        errors.append(f"interface.{key}: {iface[key]} is larger than 5 MiB")
    if data[:8] == b"\x89PNG\r\n\x1a\n":
        w, h = struct.unpack(">II", data[16:24])
        if w != h or w < 48:
            errors.append(f"interface.{key}: {iface[key]} is {w}x{h}, must be square and at least 48x48")

review = manifest.get("extensions", {}).get("com.openai", {}).get("review", {})
cases = review.get("test_cases", {})
positive, negative = cases.get("positive", []), cases.get("negative", [])
if len(positive) != 5:
    errors.append(f"review.test_cases.positive has {len(positive)} cases, MCP review needs exactly 5")
if len(negative) != 3:
    errors.append(f"review.test_cases.negative has {len(negative)} cases, MCP review needs exactly 3")
for kind, required, items in (
    ("positive", ("description", "prompt", "tools_triggered", "expected_behavior"), positive),
    ("negative", ("description", "prompt"), negative),
):
    for n, case in enumerate(items, 1):
        missing = [k for k in required if not case.get(k)]
        if missing:
            errors.append(f"review.test_cases.{kind}[{n}] is missing {', '.join(missing)}")
demo = review.get("demo_recording_url", "")
if not demo.startswith("https://") or "REPLACE" in demo:
    errors.append("review.demo_recording_url must be the reviewer-accessible HTTPS video link")

if errors:
    sys.exit("Cannot package:\n  - " + "\n  - ".join(errors))

manifest["mcpServers"] = "./.mcp.json"
out.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr(".codex-plugin/plugin.json", json.dumps(manifest, indent=2) + "\n")
    z.write(plugin / "codex.mcp.json", ".mcp.json")
    z.write(plugin / "README.md", "README.md")
    for asset in sorted({iface[key] for key in ("logo", "composerIcon")}):
        z.write(plugin / asset, asset.removeprefix("./"))
print(f"Wrote {out}")
PY
