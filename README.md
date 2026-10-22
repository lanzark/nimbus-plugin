# Nimbus plugin for Claude Code

This repository is a [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
named `lanzark`. It ships one plugin, **`nimbus`**, which connects Claude Code (or any
Claude client that installs plugins) to the Nimbus Platform MCP server.

## Install

```shell
/plugin marketplace add lanzark/nimbus-plugin
/plugin install nimbus@lanzark
```

Then authenticate — the MCP server is an OAuth 2.1 resource server, so the first call
triggers a browser login against WorkOS AuthKit:

```shell
/mcp
```

Pick `plugin:nimbus:nimbus` and follow the login flow. Once it reports `connected`, ask
Claude something like *"list my Nimbus apps"*.

## What it exposes

| Tool | What it does |
|---|---|
| `nimbus_me` | Confirm identity and organization |
| `list_apps` / `get_app` | Read the caller's apps |
| `create_nimbus_app` | Create a GitHub repo from the Nimbus template |
| `get_git_token` | Mint a short-lived git credential scoped to one repo |
| `list_env_vars` / `set_env_vars` / `delete_env_var` | App configuration (values are write-only) |
| `deploy_app` / `list_deployments` | Ship an app and watch the build |

It also exposes the `create_nimbus_app_guide` prompt, the step-by-step flow for creating
and shipping a new app.

In hook matchers and other scoped references these are named
`mcp__plugin_nimbus_nimbus__<tool>`.


## Codex and ChatGPT

The same plugin is packaged for Codex with `plugins/nimbus/.codex-plugin/plugin.json`
and `plugins/nimbus/codex.mcp.json`. The Codex MCP config is a separate file because
Codex needs `"type": "streamable-http"`, while Claude Code needs `"type": "http"`.

Try it locally from a checkout (the repo marketplace is `.agents/plugins/marketplace.json`):

```shell
codex plugin marketplace add ./
```

Enable `nimbus@lanzark`, restart the app and sign in when prompted.

To build the ZIP for the OpenAI plugin submission portal:

```shell
scripts/package-codex.sh   # writes dist/nimbus-codex.zip
```

The script checks the listing limits and the icons before packaging. The submission
checklist and the reviewer test cases are in [`submission/review.md`](submission/review.md).

## Develop

Load the plugin from a checkout without installing it:

```shell
claude --plugin-dir ./plugins/nimbus
```

Validate before pushing:

```shell
claude plugin validate ./plugins/nimbus
```

After editing plugin files in a running session, `/reload-plugins` picks them up.

## Layout

```
nimbus-plugin/
├── .claude-plugin/
│   └── marketplace.json          # this repo as a Claude Code marketplace
├── .agents/plugins/
│   └── marketplace.json          # this repo as a Codex marketplace (local testing)
├── plugins/
│   └── nimbus/
│       ├── .claude-plugin/
│       │   └── plugin.json       # Claude Code manifest
│       ├── .codex-plugin/
│       │   └── plugin.json       # Codex manifest and directory listing
│       ├── .mcp.json             # MCP server connection (Claude Code)
│       ├── codex.mcp.json        # MCP server connection and OAuth (Codex)
│       ├── assets/               # icon (nimbus-favicon-512.png)
│       └── README.md
├── scripts/
│   └── package-codex.sh          # builds the submission ZIP
└── submission/
    └── review.md                 # submission checklist and test cases
```
