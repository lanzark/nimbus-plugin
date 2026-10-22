# Lanzark Nimbus: OpenAI plugin submission

Working notes for submitting `plugins/nimbus` to the ChatGPT/Codex plugin directory.
Requirements come from the [plugin guidelines](https://developers.openai.com/plugins/plugin-guidelines)
and the [submission guide](https://developers.openai.com/plugins/deploy/submission).

## Checklist

### Package (this repo)

- [x] Icons: `logo` and `composerIcon` both use `assets/nimbus-favicon-512.png` (512×512 PNG, RGBA, 15 KB). The icon has its own white tile and gray border, so it reads on light and dark themes and needs no `logoDark` / `composerIconDark`. Icons must be square, so wide wordmarks can't be used
- [x] MCP endpoint `https://mcp.nimbus.lanzark.com/mcp`, confirmed as the stable endpoint. Its protected-resource metadata declares `resource: https://mcp.nimbus.lanzark.com/mcp`
- [x] OAuth: AuthKit (`https://caring-precipice-79.authkit.app`) publishes a `registration_endpoint`, so `client.mode: "dcr"` needs no client ID or secret
- [x] `scripts/package-codex.sh` builds `dist/nimbus-codex.zip` (manifest, `.mcp.json`, README, icon)
- [ ] Publish real pages for `supportURL` (`/support`), `privacyPolicyURL` (`/privacy`) and `termsOfServiceURL` (`/terms`) on lanzark.com, or change the URLs in `.codex-plugin/plugin.json`. Today these paths return 200 but serve the lanzark.com home page, the same as any unknown path. All four listing URLs are required for MCP review. The privacy policy must cover the data collected, purposes, recipients, retention and user controls

### MCP server (Nimbus Platform repo)

- [ ] Every tool sets `readOnlyHint`, `destructiveHint` and `openWorldHint` as explicit booleans. For example, `deploy_app`, `delete_env_var`, `set_env_vars` and `set_app_access` need `destructiveHint: true`; `list_*`, `get_app` and `nimbus_me` need `readOnlyHint: true`; every tool needs `openWorldHint: false`
- [ ] Server instructions and tool descriptions avoid wording that claims to override the platform or other instructions (for example "MANDATORY … outrank anything")
- [ ] `get_git_token` and `set_env_vars` state their side effects clearly. Credentials and secrets are a likely point of review friction
- [ ] Responses omit request IDs, trace IDs and logging metadata unless needed
- [ ] OAuth dynamic client registration works for ChatGPT, and the consent screen lists the requested permissions
- [ ] Serve the domain challenge token at `https://mcp.nimbus.lanzark.com/.well-known/openai-apps-challenge` once the portal issues it

### Account and review

- [ ] Developer verification (individual or business) in the OpenAI Platform organization settings
- [ ] Dedicated reviewer account with sample apps that signs in with a password only (no MFA, magic link or email codes)
- [ ] Demo video URL that reviewers can open
- [ ] Tested in ChatGPT desktop and mobile, and in Codex

## Positive test cases

| # | Description | Prompt | Tools triggered | Expected behavior |
|---|---|---|---|---|
| 1 | Identify the signed-in user | "Which Nimbus account and organization am I using?" | `nimbus_me` | Returns the user's name, email and active organization |
| 2 | List apps | "List my Nimbus apps" | `list_apps` | Lists the reviewer account's sample apps with their names and status |
| 3 | Inspect an app | "Show me the details of my <sample app> app" | `list_apps`, `get_app` | Shows the app's repository, URL and latest deployment |
| 4 | Set an environment variable | "Set GREETING=hello on <sample app>" | `set_env_vars` | Confirms the variable was saved, without echoing secret values |
| 5 | Deploy an app | "Deploy <sample app> and tell me when the build finishes" | `deploy_app`, `list_deployments` | Shows a summary, asks for confirmation, starts the deployment and reports its status |

## Negative test cases

| # | Description | Prompt |
|---|---|---|
| 1 | Unrelated request should not trigger Nimbus | "What's the weather in Madrid today?" |
| 2 | General coding question with no Nimbus action | "Explain the difference between let and const in JavaScript" |
| 3 | Deployment on another platform | "Deploy my site to Vercel" |
