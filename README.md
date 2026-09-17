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

## Environments

Only **dev** exists today, so the plugin points at it unconditionally:

```
https://mcp.nimbus-dev.lanzark.com/mcp
```

When a prod environment lands, add a second plugin entry (for example `nimbus-prod`) to
`.claude-plugin/marketplace.json` with its own plugin directory and URL, rather than
making this one switchable — a user can then have both installed and enable whichever
they need.

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
│   └── marketplace.json          # this repo as a marketplace
└── plugins/
    └── nimbus/
        ├── .claude-plugin/
        │   └── plugin.json       # plugin manifest
        ├── .mcp.json             # the MCP server connection
        └── README.md
```
