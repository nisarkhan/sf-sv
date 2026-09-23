# sf-sv

Claude Code plugin for the Salesforce architect team.

## sf-solution-verifier
Fact-checks a Salesforce solution document against official Salesforce sources
only (Context7 Salesforce libraries plus developer, help, architect, and
www.salesforce.com). Writes an HTML verification report next to the document.

## Install
    git clone https://github.com/nisarkhan/sf-sv.git
    cd sf-sv
    ./scripts/install.sh            # or --oauth, see scripts/README-install.md

Then open a new terminal, start `claude` in this folder, and run:

    /plugin marketplace add nisarkhan/sf-sv
    /plugin install sf-solution-verifier@sf-sv

Restart Claude Code.

## Use
    /sf-solution-verifier path/to/solution.md

## Test
    /sf-solution-verifier examples/test-solution.md
Expected: 4 problems caught, 3 confirmed, 1 "Needs account team".

## Updating
Edit skills/sf-solution-verifier/SKILL.md, bump "version" in plugin.json,
commit and push. Teammates run:

    /plugin marketplace update sf-sv

## Keys
Nobody should paste a key around. Options, in order of preference:
1. `./scripts/install.sh --oauth` - browser sign-in, no key ever seen
2. `./scripts/install.sh --proxy https://...` - team gateway holds the
   enterprise key, nothing on the teammate's machine
3. `./scripts/install.sh` - paste your own key (fine for solo testing)
Never commit a key. Never share one key across the team.
