# `nimbus`

Connects Claude Code to the Nimbus Platform MCP server so Claude can create apps, clone
them, manage their environment variables and deploy them.

- **Endpoint:** `https://mcp.nimbus.lanzark.com/mcp` (dev; streamable HTTP)
- **Auth:** OAuth 2.1 via WorkOS AuthKit — Claude Code runs the flow for you, no token or
  environment variable to configure. Run `/mcp` to sign in or re-authenticate.

The plugin also ships as a Codex/ChatGPT plugin (`.codex-plugin/plugin.json` +
`codex.mcp.json`), listed as **Lanzark Nimbus**.

Install and usage instructions are in the [repository README](../../README.md).
