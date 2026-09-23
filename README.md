# sf-sv

Claude Code plugin for the Salesforce architect team.

## sf-solution-verifier
Fact-checks a Salesforce solution document against official Salesforce sources
only (Context7 Salesforce libraries plus developer, help, architect, and
www.salesforce.com). Writes an HTML verification report next to the document.

There are two ways to set this up. Pick the one that matches your situation.

--------------------------------------------------------------------------
## SECTION 1: INDIVIDUAL KEY
For solo use, pilots, and anyone before the team gateway exists.
Each person has their own Context7 account and their own credential.
--------------------------------------------------------------------------

### 1.1 Get access to Context7
Either sign in through the browser and let the CLI hold the credential
(preferred, nothing to paste):

    git clone https://github.com/nisarkhan/sf-sv.git
    cd sf-sv
    chmod +x scripts/install.sh
    ./scripts/install.sh --oauth

Or create a key at https://context7.com/dashboard and paste it when asked:

    chmod +x scripts/install.sh
    ./scripts/install.sh

If you see "zsh: permission denied", the execute bit was lost in the clone or
download. The chmod line above fixes it, or run `bash scripts/install.sh`.

The script saves the credential to your shell profile, tests it against
Context7, and adds the Salesforce-only fetch rules to ~/.claude/settings.json.

### 1.2 Install the plugin
Open a NEW terminal window, then:

    cd sf-sv
    claude

Inside Claude Code, one command at a time:

    /plugin marketplace add nisarkhan/sf-sv
    /plugin install sf-solution-verifier@sf-sv

Choose "Install for you (user scope)". Restart Claude Code.

### 1.3 Test

    /sf-solution-verifier:sf-solution-verifier examples/test-solution.md

Expected: 4 problems caught, 3 confirmed, 1 "Needs account team".

### 1.4 Rules
- Never commit a key. Never share one key between people.
- Each account has its own monthly usage limit.
- Rotate your key if it is ever pasted into a chat, ticket, or document.

--------------------------------------------------------------------------
## SECTION 2: ENTERPRISE KEY
For the team. One enterprise key lives in a gateway you control.
Nobody else has a credential on their machine.
--------------------------------------------------------------------------

### 2.1 What the admin sets up, once
1. Stand up a small internal service that accepts MCP requests, adds the
   enterprise key as the CONTEXT7_API_KEY header, and forwards to
   https://mcp.context7.com/mcp
2. Keep the key in your normal secret store. It never leaves the server.
3. Put access behind your usual sign-on so leavers lose access automatically.
4. Optional but useful: log who queried what, for usage reporting.
5. Commit .claude/settings.json to this repo (see 2.2) with the gateway URL.

### 2.2 The settings file to commit
Save as .claude/settings.json in this repo:

    {
      "extraKnownMarketplaces": {
        "sf-sv": { "source": { "source": "github", "repo": "nisarkhan/sf-sv" } }
      },
      "enabledPlugins": { "sf-solution-verifier@sf-sv": true },
      "env": { "CONTEXT7_MCP_URL": "https://your-gateway.internal/mcp" },
      "permissions": {
        "allow": [
          "WebFetch(domain:developer.salesforce.com)",
          "WebFetch(domain:help.salesforce.com)",
          "WebFetch(domain:architect.salesforce.com)",
          "WebFetch(domain:www.salesforce.com)"
        ]
      }
    }

For coverage outside this repo folder, ask your Mac admins to push the same
content as managed settings through your device management tool.

### 2.3 What each teammate does
Everything, start to finish:

    git clone https://github.com/nisarkhan/sf-sv.git
    cd sf-sv
    claude

    /sf-solution-verifier:sf-solution-verifier examples/test-solution.md

They trust the folder when Claude Code asks. No installer, no key, no
settings to edit.

### 2.4 Verify the setup
- Connected: /mcp shows context7
- Correct target: the gateway logs show the request
- Fails safe: `env -u CONTEXT7_API_KEY -u CONTEXT7_MCP_URL claude` then run
  the test document. The skill must report that it cannot reach Context7
  rather than answering from memory.

--------------------------------------------------------------------------

## Moving from Section 1 to Section 2
1. Stand up the gateway and commit the settings file.
2. Teammates pull the repo. Their next session uses the gateway.
3. Each person removes their personal export line from ~/.zshrc.
4. Delete the individual keys in the Context7 dashboard.
Nothing about the skill, the commands, or the reports changes.

## Use
    /sf-solution-verifier:sf-solution-verifier path/to/solution.md

## Updating the skill
Edit skills/sf-solution-verifier/SKILL.md, bump "version" in plugin.json,
commit and push. Teammates run:

    /plugin marketplace update sf-sv
